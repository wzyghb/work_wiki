# 参考记录

+ [context](https://segmentfault.com/a/1190000006744213)
+ [编译版本号](https://xiaozhou.net/go-makefile-and-auto-version-2016-06-13.html)

## Mem Model

1. happen before, happen after, happen concurrency
1. init > import package > main.main

## Channel

1. Channel 没有 buffer 时，只有有 receiver 时才可以使用

## others

+ [go `struct{}` 用法](https://gocn.io/question/103)

## test and benchmark

+ [test and benchmark](https://golang.org/pkg/testing/)

## method 定义时 receiver 为 Pointer 和 Value 的差别

+ value method 可以同时接受 pointer 和 value 值
+ pointer method 只能够由一个 pointer 调用
+ pointer 方法可以修改 receiver，而 value method 只会接受一个 value 的副本
