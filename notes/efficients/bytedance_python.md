
不要用if来进行重用。
算法和业务逻辑解耦。

python导入顺序：
导入顺序遵循标准库导入->第三方库导入->应用程序导入

## 如何取名
设计做得好->名字好取—>代码好理解

评价：
+ 清晰
+ 简洁
+ 一致

### 清晰

1. 命名应该面向问题域而不是实现域。 What VS How
2. 命名可以从实现向和使用向两个方面来考虑，最好两个角度都可以cover。
3. 使用准确的词汇：Google是个比词典更好的工具。

### 简洁

#### 1. 如无必要，勿增实体
避免不需要的名字。这个变量没有必要出现，就设定为callable。
局部变量名可以重用，如i， j类似的。

#### 2. 系统性的

+ Java系：i, Impl, postfix
+ Impression -> Impr
+ Resource -> R

#### 3. 对于命名实体，名字应该包括module名，类名，避免不必要的重复

+ user。user_name -> user.name
+ user.UserLocator -> user.Locator
+ recall_name, recall_data in get_recall_result()

#### 4. 存在于1~3行的局部变量，可以使用简洁的名字。
#### 5. 当有多个局部变量需要相同的下划线前缀时，应该来创建一个更加局部的命名空间。

### 一致

风格
分层次的一致
+ 接口层：模块，类名，函数名，参数名
+ 局部变量
名字是设计的产物，应该会非常的稳定，如果一致性和准确性产生矛盾，一致性应该优先考虑。
避免对同一个东西在同一角度、同一层次有多个名字。

## 坏气味
+ 无法取一个明确的名字
  + 使用方试图以实现方命名，或者反之
  + 设计问题
+ 无法取一个简洁的名字 -- 上下文过于复杂

+ list/set: groups, users
+ dict: item2weight
+ get_xxx vs xxx
+ type conversion: as_loader, as_explorelet
+ util vs helper  工具性可重用 vs 不可重用，助手
+ Predict vs filter
+ Populate 

..let(某个小部件)
loadlet
sharelet 分享器
applet


code complete 第11章


## abc

这个模块用于在 Python 中定义 abstract base classes.

+ register(subclass)
注册一个子类作为这个 ABC 的 “虚子类”。

+ __subclasshook__(subclass) 
检查一个 subclass 是不是 ABC 的子类。这是自定义 issubclass 方法，但不需要调用 register 的另一种方法。
如果 返回 True，会认为是子类，如果返回 False，则不会被认为是子类，若返回 NotImplemented，则会用常规的方法来处理。

```python
class Foo:
    def __getitem__(self, index):
        ...
    def __len__(self):
        ...
    def get_iterator(self):
        return iter(self)

class MyIterable(metaclass=ABCMeta):

    @abstractmethod
    def __iter__(self):
        while False:
            yield None

    def get_iterator(self):
        return self.__iter__()

    @classmethod
    def __subclasshook__(cls, C):
        if cls is MyIterable:
            if any("__iter__" in B.__dict__ for B in C.__mro__):
                return True
        return NotImplemented

MyIterable.register(Foo)
```

ABC `MyIterable` 定义了一个标准迭代器方法 `__iter__` 做为抽象方法。这个实现在此处可以从 subclasses 中调用。
`__subclasshook__` 类方法在此处定义了任何实现了 __iter__ 方法的类（在其 __dict__ 中有这个方法或者通过 `__mro__` 都可以得到）也会被认为是一个 MyIterable.


class abc.ABC

+ @abc.abstractmethod
装饰器所在的类必须以 ABCMeta 为元类，或者从其继承。只有覆盖了所有的 abstractmethod 后，这个类才能够被实例化。可以使用 abstractmethod
