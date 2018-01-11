# 参考记录

+ [context](https://segmentfault.com/a/1190000006744213)
+ [编译版本号](https://xiaozhou.net/go-makefile-and-auto-version-2016-06-13.html)

## Mem Model

1. happen before, happen after, happen concurrency
1. init > import package > main.main
1. `runtime.GC(); runtime.MemStats

## Channel

1. Channel 没有 buffer 时，只有有 receiver 时才可以使用

## others

+ [go `struct{}` 用法](https://gocn.io/question/103)
+ 通常函数的返回一个变量引用时，这个变量会在堆上分配，哪些情况时特殊的？(内联函数)

## test and benchmark

+ [test and benchmark](https://golang.org/pkg/testing/)

## method 定义时 receiver 为 Pointer 和 Value 的差别

+ value method 可以同时接受 pointer 和 value 值
+ pointer method 只能够由一个 pointer 调用
+ pointer 方法可以修改 receiver，而 value method 只会接受一个 value 的副本

## Go 中的 array

+ array 是值，赋值会造成整个 array 的复制
+ 如果将 array 作为函数参数传递，那么会复制整个数组
+ array[10], array[20] 是不同的类型

## go 中返回值、defer、return 的差别

+ defer 采用先入后出的策略运行
+ return 有个将返回值复制的过程
+ 有名返回和无名返回是有差别的
+ [reference](https://studygolang.com/articles/4809)
