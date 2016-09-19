
基本功能：自动测试，共享测试的启动和关闭代码，将测试集成为集合，并且把让测试和报告架构相互独立。
基本概念：

+ test fixture： 代表为实现一个或者多个测试用例需要的准备、清理行为。比如说：创建临时或者代理的数据库、目录或者启动一个服务器进程。
+ test case：    单独的测试单元，为特别的输入集合检查特殊的响应。`unittest` 提供了一个基类：`TestCase`。
+ test suite：   test suite 是测试用例、或者 test suite 的集合。它用于集成测试以便于一起来执行。
+ test runner：  执行测试，并且将结果输出给用户，runner 可以使用图形界面，也可以使用文本接口，或者使用一个特殊的值来表示执行测试的结果。

其他：
Nose、py.test
Python 测试工具分类

启动测试

```
if __name__ == '__main__':
    unittest.main()
```

命令行工具：

```python
python -m unittest test_module1 test_module2
python -m unittest tests/test_something.py
python -m unittest -v test_module (-v 输出更多详情)
```

+ --locals: 在 tracebacks 中显示 局部变量
+ -f --failfast: 当遇到第一个错误或者失败时停止运行
+ -c --catch: 当在 test 运行时，输入 control-c 时，会等到这个测试用例运行结束后才会停止。
+ -b --buffer: 