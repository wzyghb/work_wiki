每个 gunicorn worker 大概会占用 200M 的内存空间。

## Server Model

pre-fork worker model:
+ Central master process: 不处理单独的 client 请求
+ worker processes: 处理所有的 request 和 response

## Master
+ TTIN / TTOU 增加或者减少 worker 数量
+ CHLD worker 停止了，master 会对其进行重启

## Sync Workers

## Async Workers

+ Greenlets 或者 Eventlet 和 Gevent

## Tornado Worker

## AsyncIO Workers

使用 aiohttp

## 选择合适的 Worker Type

当服务端的 worker 是同步的时，黑客可以通过慢慢地给服务器数据，以此来拖死服务器。
几个需要异步 worker 的场合：

+ 会导致长时间阻塞的调用 (如 web service)
+ 直接响应来自互联网的请求
+ 流式的请求和响应
+ 长连接 websocket
+ 轮询 long polling
+ Comet

## 选择合适数量的 worker

Gunicorn 只需要 4-12 个 worker 就可以在每秒处理成百上千个请求。Gunicorn 处理请求时，需要依赖于操作系统来提供负载均衡。一般地，我们推荐使用 `(2 * $num_cores) + 1` 作为启动的 workers。
对于一个改定的 core，一个 worker 可能正在从 socket 读取和写入数据而另一个正在处理一个请求。

一般来说服务器特定的硬件会影响最优的 worker 数量，推荐使用上面的方法估算 worker 的数量，然后使用 TTIN 和 TTOU 来调整负载直到最优。
