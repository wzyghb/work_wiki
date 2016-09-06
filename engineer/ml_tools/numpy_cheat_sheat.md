
## 基础

### ndarray 基本属性

+ ndim
+ shape
+ size
+ dtype
+ itemsize
+ data

### 创建数组

```
import numpy as np

a = np.array([1,2,3,4])
np.zeros( (3,4) )
np.ones( (2,3,4), dtype=np.int16 )
np.empty( (2,3) ) 
np.arange( 10, 30, 5 )
b = np.random.random((2,3))
a = np.ones(3, dtype=np.int32)
b = np.linspace(0,pi,3)
b.dtype.name
d = np.exp(c*1j)

```

总结：
array, zeros, zeros_like, ones, ones_like, empty, empty_like, 
arange, linspace, numpy.random.rand, numpy.random.randn, 
fromfunction, fromfile

### 基本计算

Printing Arrays
Universal Functions
Indexing, Slicing and Iterating

```python
a = np.array( [20,30,40,50] )
b = np.arange( 4 )
c = a-b
b**2
10*np.sin(a)
a<35

a = np.ones(3, dtype=np.int32)
b = np.linspace(0,pi,3)
c = a+b  # 类型自动转换

d = np.exp(c*1j)
d.dtype.name
# 'complex128'

b.sum(axis=0) 
b.min(axis=1)
b.cumsum(axis=1)

a = np.arange(10)**3
a[2]
a[2:5]

a.flat          # 迭代器
a.ravel()       # 直接返回数组
a = np.floor(10*np.random.random((3,4)))

a.reshape((m, n))   # 返回一个改变结构后的新数组
a.resize((m, n))    # 改变原数组的结构

a = np.floor(10*np.random.random((2,2)))
b = np.floor(10*np.random.random((2,2)))
np.vstack((a,b))
np.hstack((a,b))

from numpy import newaxis   # 给数组增加一个新的纬度
a = np.array([4.,2.])
a[:, newaxis]
```

数组的复制：
引用复制
view
copy

矩阵计算
```
a.transpose()
np.linalg.inv(a)
```

[numpy的方法查询](http://docs.scipy.org/doc/numpy-dev/user/quickstart.html#functions-and-methods-overview)

