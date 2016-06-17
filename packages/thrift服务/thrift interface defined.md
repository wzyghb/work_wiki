## 安装


[mac上安装](https://thrift.apache.org/docs/install/os_x)
[libevent](http://libevent.org/)
[boost](http://www.boost.org/)


### 1. openssl问题

libenvent make 时会出现这个问题。

```
brew install openssl
brew link openssl --force
```

#### 2. bison 问题解决

```
brew install bison
brew link bison --forece
brew unlink bison (如果需要)
```

## thrift 数据类型

#### 基本类型 Base Type

+ bool: A boolean value (true or false)
+ byte: An 8-bit signed integer
+ i16: A 16-bit signed integer
+ i32: A 32-bit signed integer
+ i64: A 64-bit signed integer
+ double: A 64-bit floating point number
+ string: A text string encoded using UTF-8 encoding

注意这个定义中没有无符号整数的定义，因为在大部分编程语言中没有无符号数的定义。

#### 特殊类型 Special Types

binary: a sequence of unencoded bytes

#### 结构体 Structs

和OOP中的类的概念类似，但是没有继承的性质。结构体的每一个域都具有自己的类型，并且有一个唯一的名称标识。
后面的Thrift IDF中有相关的定义。

#### 容器 Containers

大部分语言中包含的容器。

+ list: 有序的元素列表，可以转换为STL vector，Java ArrayList...
+ set: 无序且元素具有唯一性的集合。 STL set， Java HashSet， Python set
+ map: STL map, Java HashMap, PHP associative array, Python/Ruby dictionary

为了具有较大的适应性，最好所有的map的key都是原始类型。

#### 异常 Exceptions

异常的功能和结构是类似的，但是会继承自一个语言相关的基类。

#### 服务 Serveices

可以使用Thrift类型定义服务，其语义在OOP语言中和定义接口（纯虚类的定义）相同。Thrift编译器会生成
完整的客户端和服务端接口stubs。

一个service由一个集合的命名函数组成，每个函数包含参数和返回类型。

注意void是不合法的返回类型。此外可以更改keyword来增加一个void函数，生成的代码将不会等待一个response。
注意纯粹的void函数将不会返回一个response到client并保证这个操作已经在服务器上执行完成了。
当使用oneway method调用时，client仅会保证请求已经在传输层成功发送了。

## 例子

### 1

```
/***        tutorial.thrift  ***/

/**
 * The first thing to know about are types. The available types in Thrift are:
 *
 *  bool        Boolean, one byte
 *  i8 (byte)   Signed 8-bit integer
 *  i16         Signed 16-bit integer
 *  i32         Signed 32-bit integer
 *  i64         Signed 64-bit integer
 *  double      64-bit floating point value
 *  string      String
 *  binary      Blob (byte array)
 *  map<t1,t2>  Map from one type to another
 *  list<t1>    Ordered list of one type
 *  set<t1>     Set of unique elements of one type
 *
 * Did you also notice that Thrift supports C style comments?
 * Thrift 支持C风格的注释。
 */

/**
 * Thrift files can reference other Thrift files to include common struct
 * and service definitions. These are found using the current path, or by
 * searching relative to any paths specified with the -I compiler flag.
 * Thrift文件可以引用其他的Thrift文件来包含通用的结构和服务定义。在当前目录下查找，或者由-I
 * 指定的路径。
 * 
 * Included objects are accessed using the name of the .thrift file as a
 * prefix. i.e. shared.SharedObject
 * 
 */
include "shared.thrift"

/**
 * Thrift files can namespace, package, or prefix their output in various
 * target languages.
 */

namespace java tutorial
namespace py tutorial

/**
 * Thrift lets you do typedefs to get pretty names for your types. Standard
 * C style here.
 * 使用typedef语句
 */
typedef i32 MyInteger

/**
 * Thrift also lets you define constants for use across languages. Complex
 * types and structs are specified using JSON notation.
 * 可以定义常量，而复杂的结构使用JSON标注实现。
 */
const i32 INT32CONSTANT = 9853
const map<string,string> MAPCONSTANT = {'hello':'world', 'goodnight':'moon'}

/**
 * You can define enums, which are just 32 bit integers. Values are optional
 * and start at 1 if not supplied, C style again.
 * 可以定义enums，这会是32位的整数。
 */
enum Operation {
  ADD = 1,
  SUBTRACT = 2,
  MULTIPLY = 3,
  DIVIDE = 4
}

/**
 * Structs are the basic complex data structures. They are comprised of fields
 * which each have an integer identifier, a type, a symbolic name, and an
 * optional default value.
 * 结构体是基础的复杂数据结构。其域(field)由一个整数、一个类型标记, 一个符号名称，
 * 以及一个可选的默认值。
 *
 * Fields can be declared "optional", which ensures they will not be included
 * in the serialized output if they aren't set.  Note that this requires some
 * manual management in some languages.
 * 域也可被定义为可选('optional')的，这将保证如果他们没有在序列化输出中设定，
 * 他们将不会再输出序列化文件中包含。注意在一些语言中这需要人工处理。
 */
struct Work {
  1: i32 num1 = 0,
  2: i32 num2,
  3: Operation op,
  4: optional string comment,
}

/**
 * Structs can also be exceptions, if they are nasty.
 * 结构也可以是exceptions，但这样会比较危险。
 */
exception InvalidOperation {
  1: i32 whatOp,
  2: string why
}

/**
 * Ahh, now onto the cool part, defining a service. Services just need a name
 * and can optionally inherit from another service using the extends keyword.
 * 只需要一个名字就可以定义服务，服务可以可选地继承自另一个服务。
 * 
 */
service Calculator extends shared.SharedService {

  /**
   * A method definition looks like C code. It has a return type, arguments,
   * and optionally a list of exceptions that it may throw. Note that argument
   * lists and exception lists are specified using the exact same syntax as
   * field lists in struct or exception definitions.
   * 
   * 注意这个方法的定义，其参数和可能抛出的异常均使用和结构类似的定义方式。
   */

   void ping(),

   i32 add(1:i32 num1, 2:i32 num2),

   i32 calculate(1:i32 logid, 2:Work w) throws (1:InvalidOperation ouch),

   /**
    * This method has a oneway modifier. That means the client only makes
    * a request and does not listen for any response at all. Oneway methods
    * must be void.
    */
   oneway void zip()

}

/**
 * That just about covers the basics. Take a look in the test/ folder for more
 * detailed examples. After you run this file, your generated code shows up
 * in folders with names gen-<language>. The generated code isn't too scary
 * to look at. It even has pretty indentation.
 */


/***        shared.thrift  ***/

namespace java shared
namespace py shared

struct SharedStruct {
  1: i32 key
  2: string value
}

service SharedService {
  SharedStruct getStruct(1: i32 key)
}
```