
+ weakref
+ thread.Condition 感觉和 Java 的设计区别较大

## ThreadPoolExecutor 相关代码阅读笔记

python 做项目时，比较简单粗暴，很少使用线程，正好有个并发的需求，需要多个并发请求，请求 cassandra 和 es 这种集群的服务，这种集群服务主要的性能瓶颈在于 IO，因而可以使用 python 本身的线程模型，就可以取得较好的效果。 GIL 无影响。

因为要获取并发请求返回的结果，又不想使用锁来处理，所以考虑使用 Future 模型，python 中新加的包是 `concurrent.futures`，
```python
_threads_queues = weakref.WeakKeyDictionary()

def _worker(executor_reference, work_queue):
    try:
        while True:
            work_item = work_queue.get(block=True)
            if work_item is not None:
                work_item.run()
                # Delete references to object. See issue16284
                del work_item
                continue
            executor = executor_reference()
            # Exit if:
            #   - The interpreter is shutting down OR
            #   - The executor that owns the worker has been collected OR
            #   - The executor that owns the worker has been shutdown.
            if _shutdown or executor is None or executor._shutdown:
                # Notice other workers
                work_queue.put(None)
                return
            del executor
    except BaseException:
        _base.LOGGER.critical('Exception in worker', exc_info=True)
    
class ThreadPoolExecutor(_base.Executor):
    def __init__(self, max_workers=None):
        if max_workers is None:
            # 使用 cpu 的数目计算最大的线程开启数目
            max_workers = (os.cpu_count() or 1) * 5 
        if max_workers <= 0:
            raise ValueError("max_workers must be greater than 0")

        self._max_workers = max_workers
        # 内部使用的队列
        self._work_queue = queue.Queue()
        # 使用线程的接口
        self._threads = set()
        # 该线程池是否已关闭
        self._shutdown = False
        # 关闭使用的读取锁
        self._shutdown_lock = threading.Lock()

    def submit(self, fn, *args, **kwargs):
        with self._shutdown_lock:
            if self._shutdown:
                raise RuntimeError('cannot schedule new futures after shutdown')
            
            # 首先创建一个处理结果的 Future
            f = _base.Future()
            # 包装为一个工作项
            w = _WorkItem(f, fn, args, kwargs)

            # 将工作项 push 到队列中
            self._work_queue.put(w)
            # 每次提交完后，调整数量
            self._adjust_thread_count()
            return f
    submit.__doc__ = _base.Executor.submit.__doc__

    def _adjust_thread_count(self):
        # When the executor gets lost, the weakref callback will wake up
        # the worker threads.
        # 当弱引用被回收时，向队列中加入一个 None
        def weakref_cb(_, q=self._work_queue):
            # 有线程被回收时，向队列中发送一个 None
            q.put(None)
        # TODO(bquinlan): Should avoid creating new threads if there are more
        # idle threads than items in the work queue.
        # 如果线程池中的线程数量小于线程池的最大线程数设置，则新增一个线程。
        if len(self._threads) < self._max_workers:
            t = threading.Thread(target=_worker,
                                 args=(weakref.ref(self, weakref_cb),
                                       self._work_queue))
            # 设置为守护线程
            t.daemon = True
            t.start()
            self._threads.add(t)

            # 将线程和队列的对应关系记录到一个 weak 字典中。
            _threads_queues[t] = self._work_queue

    def shutdown(self, wait=True):
        with self._shutdown_lock:
            self._shutdown = True
            self._work_queue.put(None)
        if wait:
            for t in self._threads:
                t.join()
```

疑问: _work_queue 中的 None 不会被消费，会越来越多吗？

_WorkItem 解析

```python
class _WorkItem(object):
    def __init__(self, future, fn, args, kwargs):
        self.future = future
        self.fn = fn
        self.args = args
        self.kwargs = kwargs

    def run(self):
        if not self.future.set_running_or_notify_cancel():
            return

        try:
            result = self.fn(*self.args, **self.kwargs)
        except BaseException as e:
            # 失败，在 future 中填充失败
            self.future.set_exception(e)
        else:
            # 成功，在 future 中填充成功
            self.future.set_result(result)
```

## Executor 接口

```python
class Executor(object):
    """This is an abstract base class for concrete asynchronous executors."""

    def submit(self, fn, *args, **kwargs):
        """提交一个可调用的对象及其参数

        调用可执行对象为 `fn(*args, **kwargs)` 并调度执行。并返回一个 Future 实例。
        """
        raise NotImplementedError()

    def map(self, fn, *iterables, timeout=None, chunksize=1):
        """Returns an iterator equivalent to map(fn, iter).

        Args:
            fn: A callable that will take as many arguments as there are
                passed iterables.
            timeout: The maximum number of seconds to wait. If None, then there
                is no limit on the wait time.
            chunksize: The size of the chunks the iterable will be broken into
                before being passed to a child process. This argument is only
                used by ProcessPoolExecutor; it is ignored by
                ThreadPoolExecutor.

        Returns:
            An iterator equivalent to: map(func, *iterables) but the calls may
            be evaluated out-of-order.

        Raises:
            TimeoutError: If the entire result iterator could not be generated
                before the given timeout.
            Exception: If fn(*args) raises for any values.
        """
        if timeout is not None:
            end_time = timeout + time.time()

        fs = [self.submit(fn, *args) for args in zip(*iterables)]

        # Yield must be hidden in closure so that the futures are submitted
        # before the first iterator value is required.
        def result_iterator():
            try:
                for future in fs:
                    if timeout is None:
                        yield future.result()
                    else:
                        yield future.result(end_time - time.time())
            finally:
                for future in fs:
                    future.cancel()
        return result_iterator()

    def shutdown(self, wait=True):
        """Clean-up the resources associated with the Executor.

        It is safe to call this method several times. Otherwise, no other
        methods can be called after this one.

        Args:
            wait: If True then shutdown will not return until all running
                futures have finished executing and the resources used by the
                executor have been reclaimed.
        """
        pass

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.shutdown(wait=True)
        return False
```

## Future

+ 本身是有状态的，共计有 5 个状态
+ 修改状态时要加锁

```python

_FUTURE_STATES = [
    PENDING,
    RUNNING,
    CANCELLED,
    CANCELLED_AND_NOTIFIED,
    FINISHED
]

class Future(object):
    """Represents the result of an asynchronous computation."""

    def __init__(self):
        """Initializes the future. Should not be called by clients."""
        self._condition = threading.Condition()
        self._state = PENDING
        self._result = None
        self._exception = None
        self._waiters = []
        self._done_callbacks = []

    def _invoke_callbacks(self):
        for callback in self._done_callbacks:
            try:
                # 回调函数
                callback(self)
            except Exception:
                LOGGER.exception('exception calling callback for %r', self)

    def __repr__(self):
        with self._condition:
            if self._state == FINISHED:
                if self._exception:
                    return '<%s at %#x state=%s raised %s>' % (
                        self.__class__.__name__,
                        id(self),
                        _STATE_TO_DESCRIPTION_MAP[self._state],
                        self._exception.__class__.__name__)
                else:
                    return '<%s at %#x state=%s returned %s>' % (
                        self.__class__.__name__,
                        id(self),
                        _STATE_TO_DESCRIPTION_MAP[self._state],
                        self._result.__class__.__name__)
            return '<%s at %#x state=%s>' % (
                    self.__class__.__name__,
                    id(self),
                   _STATE_TO_DESCRIPTION_MAP[self._state])

    def cancel(self):
        """如果可能，取消这个 Future

        如果成功取消，返回 True，否则返回 False。
        一个 Future 在 running 和 completed 状态下不能够取消。
        """
        with self._condition:
            if self._state in [RUNNING, FINISHED]:
                return False

            if self._state in [CANCELLED, CANCELLED_AND_NOTIFIED]:
                return True

            self._state = CANCELLED
            self._condition.notify_all()

        self._invoke_callbacks()
        return True

    def cancelled(self):
        """是否已经取消。"""
        with self._condition:
            return self._state in [CANCELLED, CANCELLED_AND_NOTIFIED]

    def running(self):
        """是否正在运行。"""
        with self._condition:
            return self._state == RUNNING

    def done(self):
        """是否已经结束。"""
        with self._condition:
            return self._state in [CANCELLED, CANCELLED_AND_NOTIFIED, FINISHED]

    def __get_result(self):
        if self._exception:
            raise self._exception
        else:
            return self._result

    def add_done_callback(self, fn):
        """注册后，Future 完成后会调用这个函数

        Args:
            fn: A callable that will be called with this future as its only
                argument when the future completes or is cancelled. The callable
                will always be called by a thread in the same process in which
                it was added. If the future has already completed or been
                cancelled then the callable will be called immediately. These
                callables are called in the order that they were added.
            fn: 这个可执行对象会在 future 完成或者取消时，以 future 自己为参数进行调用。
                这个 callable 对象总是会在 add 它的进程中的某个线程中被调用。
                这些回调函数会以加入的顺序被调用。
        """
        with self._condition:
            if self._state not in [CANCELLED, CANCELLED_AND_NOTIFIED, FINISHED]:
                # 如果还没有完成，加入的列表中
                self._done_callbacks.append(fn)
                return
        # 已经完成，直接进行调用
        fn(self)

    def result(self, timeout=None):
        """返回执行结果

        Args:
            timeout: The number of seconds to wait for the result if the future
                isn't done. If None, then there is no limit on the wait time.

        Returns:
            The result of the call that the future represents.

        Raises:
            CancelledError: If the future was cancelled.
            TimeoutError: If the future didn't finish executing before the given
                timeout.
            Exception: If the call raised then that exception will be raised.
        """
        with self._condition:
            if self._state in [CANCELLED, CANCELLED_AND_NOTIFIED]:
                # 如果是取消，则抛出异常。
                raise CancelledError()
            elif self._state == FINISHED:
                # 停止，获得结果
                return self.__get_result()

            # 使用条件变量进行等待
            self._condition.wait(timeout)

            if self._state in [CANCELLED, CANCELLED_AND_NOTIFIED]:
                raise CancelledError()
            elif self._state == FINISHED:
                return self.__get_result()
            else:
                raise TimeoutError()

    def exception(self, timeout=None):
        """Return the exception raised by the call that the future represents.

        Args:
            timeout: The number of seconds to wait for the exception if the
                future isn't done. If None, then there is no limit on the wait
                time.

        Returns:
            The exception raised by the call that the future represents or None
            if the call completed without raising.

        Raises:
            CancelledError: If the future was cancelled.
            TimeoutError: If the future didn't finish executing before the given
                timeout.
        """

        with self._condition:
            if self._state in [CANCELLED, CANCELLED_AND_NOTIFIED]:
                raise CancelledError()
            elif self._state == FINISHED:
                return self._exception

            self._condition.wait(timeout)

            if self._state in [CANCELLED, CANCELLED_AND_NOTIFIED]:
                raise CancelledError()
            elif self._state == FINISHED:
                return self._exception
            else:
                raise TimeoutError()

    # The following methods should only be used by Executors and in tests.
    def set_running_or_notify_cancel(self):
        """Mark the future as running or process any cancel notifications.

        Should only be used by Executor implementations and unit tests.

        If the future has been cancelled (cancel() was called and returned
        True) then any threads waiting on the future completing (though calls
        to as_completed() or wait()) are notified and False is returned.

        If the future was not cancelled then it is put in the running state
        (future calls to running() will return True) and True is returned.

        This method should be called by Executor implementations before
        executing the work associated with this future. If this method returns
        False then the work should not be executed.

        Returns:
            False if the Future was cancelled, True otherwise.

        Raises:
            RuntimeError: if this method was already called or if set_result()
                or set_exception() was called.
        """
        with self._condition:
            if self._state == CANCELLED:
                self._state = CANCELLED_AND_NOTIFIED
                for waiter in self._waiters:
                    waiter.add_cancelled(self)
                # self._condition.notify_all() is not necessary because
                # self.cancel() triggers a notification.
                return False
            elif self._state == PENDING:
                self._state = RUNNING
                return True
            else:
                LOGGER.critical('Future %s in unexpected state: %s',
                                id(self),
                                self._state)
                raise RuntimeError('Future in unexpected state')

    def set_result(self, result):
        """将执行的返回结果绑定到 future。

        只能由 Executor 实现和单测使用
        """
        with self._condition:
            self._result = result
            self._state = FINISHED
            for waiter in self._waiters:
                waiter.add_result(self)
            self._condition.notify_all()
        self._invoke_callbacks()

    def set_exception(self, exception):
        """Sets the result of the future as being the given exception.

        Should only be used by Executor implementations and unit tests.
        """
        with self._condition:
            self._exception = exception
            self._state = FINISHED
            for waiter in self._waiters:
                waiter.add_exception(self)
            self._condition.notify_all()
        self._invoke_callbacks()
```

## as_complete

```python

class _Waiter(object):
    """Provides the event that wait() and as_completed() block on."""
    def __init__(self):
        self.event = threading.Event()
        self.finished_futures = []

    def add_result(self, future):
        self.finished_futures.append(future)

    def add_exception(self, future):
        self.finished_futures.append(future)

    def add_cancelled(self, future):
        self.finished_futures.append(future)

class _AsCompletedWaiter(_Waiter):
    """Used by as_completed()."""

    def __init__(self):
        super(_AsCompletedWaiter, self).__init__()
        self.lock = threading.Lock()

    def add_result(self, future):
        with self.lock:
            super(_AsCompletedWaiter, self).add_result(future)
            self.event.set()

    def add_exception(self, future):
        with self.lock:
            super(_AsCompletedWaiter, self).add_exception(future)
            self.event.set()

    def add_cancelled(self, future):
        with self.lock:
            super(_AsCompletedWaiter, self).add_cancelled(future)
            self.event.set()

class _FirstCompletedWaiter(_Waiter):
    """Used by wait(return_when=FIRST_COMPLETED)."""

    def add_result(self, future):
        super().add_result(future)
        self.event.set()

    def add_exception(self, future):
        super().add_exception(future)
        self.event.set()

    def add_cancelled(self, future):
        super().add_cancelled(future)
        self.event.set()

class _AllCompletedWaiter(_Waiter):
    """Used by wait(return_when=FIRST_EXCEPTION and ALL_COMPLETED)."""

    def __init__(self, num_pending_calls, stop_on_exception):
        self.num_pending_calls = num_pending_calls
        self.stop_on_exception = stop_on_exception
        self.lock = threading.Lock()
        super().__init__()

    def _decrement_pending_calls(self):
        with self.lock:
            self.num_pending_calls -= 1
            if not self.num_pending_calls:
                self.event.set()

    def add_result(self, future):
        super().add_result(future)
        self._decrement_pending_calls()

    def add_exception(self, future):
        super().add_exception(future)
        if self.stop_on_exception:
            self.event.set()
        else:
            self._decrement_pending_calls()

    def add_cancelled(self, future):
        super().add_cancelled(future)
        self._decrement_pending_calls()
    

def _create_and_install_waiters(fs, return_when):
    if return_when == _AS_COMPLETED:
        waiter = _AsCompletedWaiter()
    elif return_when == FIRST_COMPLETED:
        waiter = _FirstCompletedWaiter()
    else:
        pending_count = sum(
                f._state not in [CANCELLED_AND_NOTIFIED, FINISHED] for f in fs)

        if return_when == FIRST_EXCEPTION:
            waiter = _AllCompletedWaiter(pending_count, stop_on_exception=True)
        elif return_when == ALL_COMPLETED:
            waiter = _AllCompletedWaiter(pending_count, stop_on_exception=False)
        else:
            raise ValueError("Invalid return condition: %r" % return_when)

    for f in fs:
        f._waiters.append(waiter)

    return waiter


def as_completed(fs, timeout=None):
    """An iterator over the given futures that yields each as it completes.

    Args:
        fs: The sequence of Futures (possibly created by different Executors) to
            iterate over.
        timeout: The maximum number of seconds to wait. If None, then there
            is no limit on the wait time.

    Returns:
        按照 future 的完成 (finished or cancelled) 顺序返回 futures。如果 future 是 复制的
        那么只会被返回一次。

    Raises:
        TimeoutError: If the entire result iterator could not be generated
            before the given timeout.
    """
    if timeout is not None:
        end_time = timeout + time.time()

    fs = set(fs)
    with _AcquireFutures(fs):
        finished = set(
                f for f in fs
                if f._state in [CANCELLED_AND_NOTIFIED, FINISHED])
        pending = fs - finished
        waiter = _create_and_install_waiters(fs, _AS_COMPLETED)

    try:
        yield from finished

        while pending:
            if timeout is None:
                wait_timeout = None
            else:
                wait_timeout = end_time - time.time()
                if wait_timeout < 0:
                    raise TimeoutError(
                            '%d (of %d) futures unfinished' % (
                            len(pending), len(fs)))

            waiter.event.wait(wait_timeout)

            with waiter.lock:
                finished = waiter.finished_futures
                waiter.finished_futures = []
                waiter.event.clear()

            for future in finished:
                yield future
                pending.remove(future)

    finally:
        for f in fs:
            with f._condition:
                f._waiters.remove(waiter)
```


 ## java 中 Lock 和 Condition 的总结

 ```java
public ArrayBlockingQueue(int capacity, boolean fair) {

        if (capacity <= 0)
            throw new IllegalArgumentException();
        //创建数组    
        this.items = new Object[capacity];
        //创建锁和阻塞条件
        lock = new ReentrantLock(fair);   
        notEmpty = lock.newCondition();
        notFull =  lock.newCondition();
    }
//添加元素的方法
public void put(E e) throws InterruptedException {
        checkNotNull(e);
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            while (count == items.length)
                notFull.await();
            //如果队列不满就入队
            enqueue(e);
        } finally {
            lock.unlock();
        }
    }
 //入队的方法
 private void enqueue(E x) {
        final Object[] items = this.items;
        items[putIndex] = x;
        if (++putIndex == items.length)
            putIndex = 0;
        count++;
        notEmpty.signal();
    }
 //移除元素的方法
 public E take() throws InterruptedException {
        final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            while (count == 0)
                notEmpty.await();
            return dequeue();
        } finally {
            lock.unlock();
        }
    }
 //出队的方法
 private E dequeue() {
        final Object[] items = this.items;
        @SuppressWarnings("unchecked")
        E x = (E) items[takeIndex];
        items[takeIndex] = null;
        if (++takeIndex == items.length)
            takeIndex = 0;
        count--;
        if (itrs != null)
            itrs.elementDequeued();
        notFull.signal();
        return x;
 ```
