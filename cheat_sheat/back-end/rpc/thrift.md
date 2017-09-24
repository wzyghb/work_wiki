# thrift 使用

## reference

+ [thrift 概述](http://elf8848.iteye.com/blog/1960131)
+ [thrift 设计](http://calvin1978.blogcn.com/articles/apache-thrift.html)
+ [thrift 原理](http://itindex.net/detail/46718-thrift-%E5%8E%9F%E7%90%86)

## 安装

+ [mac上安装](https://thrift.apache.org/docs/install/os_x)
+ [libevent](http://libevent.org/)
+ [boost](http://www.boost.org/)

### 1. openssl问题

libenvent make 时会出现这个问题。

```bash
brew install openssl
brew link openssl --force
```

#### 2. bison 问题解决

```bash
brew install bison
brew link bison --forece
brew unlink bison (如果需要)
```

## thrift 数据类型

### 基本类型 Base Type

| type | description |
| :--- | :--- |
| bool | A boolean value (true or false) |
| byte | An 8-bit signed integer |
| i16  | A 16-bit signed integer |
| i32  | A 32-bit signed integer |
| i64  | A 64-bit signed integer |
| double | A 64-bit floating point number |
| string | A text string encoded using UTF-8 encoding |

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

```thrift
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
 * Thrift文件可以引用其他的 Thrift 文件来包含通用的结构和服务定义。在当前目录下查找，或者由-I
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

## 概念

### 1 Thrift 的网络栈

```sh
 +-------------------------------------------+
  | Server                                    |
  | (single-threaded, event-driven etc)       |
  +-------------------------------------------+
  | Processor                                 |
  | (compiler generated)                      |
  +-------------------------------------------+
  | Protocol                                  |
  | (JSON, compact etc)                       |
  +-------------------------------------------+
  | Transport                                 |
  | (raw TCP, HTTP etc)                       |
  +-------------------------------------------+
```

### 2 Transport

提供了从网络读写的抽象。

+ TSocket: 使用 阻塞的 socket I/O 用于传输
+ TFramedTransport: 以 frame 的形式发送数据，每个 frame 以某个长度预处理，当使用非阻塞服务器时，应该要使用这种 Transport。
+ TFileTransport: 这种 transport 会写入到一个文件中，这种传输没有在 Java 实现中支持。
+ TMemoryTransport: 使用内存实现 I/O，在 Java 中，简单地使用了一个 ByteArrayOutputStream 来实现。
+ TZlibTransport: 使用 zlib 实现压缩，需要和另一个 transport 来协同，在 Java 实现中不可用。
+ TBufferedTransport: 使用了缓存

API：

```sh
TTransport {
    open
    close
    isOpen
    read
    write
    flush
}

TServerTransport {
    open
    listen
    accept
    close
}
```

### 3 Protocal

协议层主要实现了序列化和反序列化,这个抽象实现了传输表示和数据结构的解耦。 

#### 1 API，支持两个功能：双向的直接序列化消息；基本类型、结构体的编码

```sh
writeMessageBegin(name, type, seq)
writeMessageEnd()
writeStructBgin(name)
writeStructEnd()
writeFieldBegin(name, type, id)
writeFieldEnd()
writeFieldStop()
writeMapBegin(ktype, vtype, size)
writeMapEnd()
writeListBegin(etype, size)
writeListEnd()
writeSetBegin(etype, size)
writeSetEnd()
writeBool(bool)
writeByte(byte)
writeI16(i16)
writeI32(i32)
writeI64(i64)
writeDouble(double)
writeString(string)

name, type, seq = readMessageBegin()
readMessageEnd()
name = readStructBegin()
readStructEnd()
name, type, id = readFieldBegin()
readFieldEnd()
k, v, size = readMapBegin()
readMapEnd()
etype, size = readListBegin()
readListEnd()
etype, size = readSetBegin()
readSetEnd()
bool = readBool()
byte = readByte()
i16 = readI16()
i32 = readI32()
i64 = readI64()
double = readDouble()
string = readString()
```

注意每个 `write` 都有一个对应的 `read` 的函数以及 `writeFieldStop`，这是一个特殊的方法，会在结束的时候调用，
用于 reading 的是 `readFileBegin()`, `readStructEnd()`, 生产的代码依赖于这些调用以确保每个用一种协议编码的序列可以用对应的协议。

#### 2 Structure（难 回看）

Thrift 的结构设计用于支持流式的协议。实现永远不需要进行 frame 或者在 encoding 之前计算所有数据的长度。在某些场景下这对性能非常重要。
Struct 并没有将数据的长度预先编码，而是将域的序列编码，每个域都有一个类型特征和独立的域标识符，这些类型标识使得协议可以安全地解释和解码数据，无需对
idl 进行访问。一个特殊的 STOP 类型标识结构体的结束，因为所有的基本类型可以直接读取，所有的结构体也可以直接读取，因而 Thrift 协议是自界定的，不需要帧或者编码
协议的限制。
当不需要 stream 或者 framing 更好时，可以简单的在传输层使用 TFramedTransport 即可实现。

#### 3 实现

直接将所有数据写入为二进制格式：整数类型直接转化为网络字节序，字符串也转化为和他们长度相同字节长度的序列，所有的消息的域的头部使用原始的整数序列化结构写入。
字符串的名字会被忽略。
我们决定避免一些极端的存储优化，比如将小的的整数转化为 ASCII或者 7 bit连续结构，这些方式会使得问题不再清楚简单。如果遇到性能问题，也可以比较容易地替换这些策略。

Thrift 实现了下面的协议：

+ TBinaryProtocal：一个直接的二进制格式，将数字之之间编码为二进制，而不是转化为文本。
+ TCompactProtocal：非常高效，数据的压缩编码，详细见下文。
+ TDenseProtocal：和 TCompactProtocal 类似，但是会在传输时剥去元数据，而在接收处再加上这些元信息，TDenseProtocal 目前还处于测试阶段。
+ TJSONProtocal：使用 JSON 来编码数据。
+ TSimpleJSONProtocal: 一个只写，使用 json 的协议，适合于由脚本语言进行解析。
+ TDebugProtocal：使用一种可以由人直接阅读的格式，用于在 debugging 时辅助。

### 4 Versioning

当遇到版本和数据定义的变化时， Thrift 也具有鲁棒性。这使得服务可以实现阶段性的改变。系统必须可以支持历史数据从 log 文件中读取，以及 过期的新服务器的过期客户端请求。

#### 1 文件标识 Field identifier

每一个 Thrift struct 中的成员都有一个唯一的域标识符，组合域标识符和类型特征使得每个域的标识都是唯一的。Thrift 定义语言支持自动填充域标识符，但清楚地
设定标识符在编程实践上更好。
为了避免手工和自动地标识设定，当手动设置的标识符小于等于 -1 时域和标识符会被忽略。
当数据被反序列化时，生成的代码会使用这些标识符来识别域并确定其是否和定义文件中的域对其与否。如果域的标识符不能够被识别，那么生成的代码会使用类型特征来跳过
不可识别的部分并且不会报错。
函数参数中也是用域标识符，实际上，参数列表不但在后端使用了结构体来表示，而且在前端编译系统中使用了相同的代码。这使得函数参数的修改也是版本安全的。

```thrift
service StringCache {
    void set(1:i32 key, 2:string value),
    string get(1:i32 key) throws (1:KeyNotFound knf),
    void delete(1:i32 key)
}
```

#### 2 Isset

当遇到 Unexpected 的域时，应该可以安全的忽略并舍弃这个域，当没有找到 expected 的 field 时，必须提醒开发者这个问题，这个实现是通过内部的 isset 结构体
来定义对象的。（Isset 在 null-php，None-python，nil-Ruby 时发挥作用）。基本地，每个 Thrift 结构体内部的 isset 对象为结构体中的每个域都保留一个
boolean 值，这个表示这个域是否在结构体中有所表示。当一个 reader 收到一个结构，他应当在这个域被设定之前检查这个值。例子：

```example
class Example {
  public:
    Example() :
      number(10),
      bigNumber(0),
      decimals(0),
      name("thrifty") {}
    int32_t number;
    int64_t bigNumber;
    double decimals;
    std::string name;

    struct __isset {
      __isset() :
        number(false),
        bigNumber(false),
        decimals(false),
        name(false) {}
      bool number;
      bool bigNumber;
      bool decimals;
      bool name;
    } __isset;
...
}
```

#### 3 例子分析

1. 增加域，old client，new server。旧客户端不会发送增加的域，因而新的服务器端会收到过期的请求。
1. 删除域， 旧的 client， 新的 server。旧的 client 会发送删除的域，新的服务器会忽略这个值。
1. 增加域，新的客户端，旧的服务器，新的客户端会发送一个域，旧的夫妻不能够识别，旧的服务器会忽略这个值然后像以前一样处理数据。
1. 删除域，新的客户端，旧的服务器。这是最危险的情况，旧的服务器不一定有适合于丢失的域的默认的处理行为。在这种情况下，推荐先启动新的服务器，再启动新的客户端。

### 5 RPC 实现

#### 1 Processor（TProcessor）

Processor 接收输入和输出协议的参数，从输入读取数据，通过由用户定义的 Handler 处理数据然后写入到 output 中。

```sh
interface TProcessor {
    bool process(TProtocol in, TProtocol out) throws TException
}
```

化为输出输入两部分是一个比较基本的抽象。

#### 2 代码生成

```sh
Service.thrift
  =>
Service.cpp
  interface ServiceIf
  class ServiceClient : virtual ServiceIf
    TProtocol in
    TProtocol out
  class ServiceProcessor : TProcessor
    ServiceIf handler

ServiceHandler.cpp
  class ServiceHandler : virtual ServiceIf
TServer.cpp
  TServer(TProcessor processor,
          TServerTransport transport,
          TTransportFactory tfactory,
          TProtocolFactory pfactory)
  serve()
```

> 代码示例 Python

ttypes.py 中生成的实例：

```python
class Response(object):
  """
  Attributes:
   - items
  """

  __slots__ = [
    'items',
   ]

  thrift_spec = (
    None, # 0
    (1, TType.LIST, 'items', (TType.STRUCT,(Item, Item.thrift_spec)), None, ), # 1
  )

  def __init__(self, items=None,):
    self.items = items

  def read(self, iprot):
    if iprot.__class__ == TBinaryProtocol.TBinaryProtocolAccelerated and isinstance(iprot.trans, TTransport.CReadableTransport) and self.thrift_spec is not None and fastbinary is not None:
      fastbinary.decode_binary(self, iprot.trans, (self.__class__, self.thrift_spec))
      return
    iprot.readStructBegin()
    while True:
      (fname, ftype, fid) = iprot.readFieldBegin()
      if ftype == TType.STOP:
        break
      if fid == 1:
        if ftype == TType.LIST:
          self.items = []
          (_etype3, _size0) = iprot.readListBegin()
          for _i4 in range(_size0):
            _elem5 = Item()
            _elem5.read(iprot)
            self.items.append(_elem5)
          iprot.readListEnd()
        else:
          iprot.skip(ftype)
      else:
        iprot.skip(ftype)
      iprot.readFieldEnd()
    iprot.readStructEnd()

  def write(self, oprot):
    if oprot.__class__ == TBinaryProtocol.TBinaryProtocolAccelerated and self.thrift_spec is not None and fastbinary is not None:
      oprot.trans.write(fastbinary.encode_binary(self, (self.__class__, self.thrift_spec)))
      return
    oprot.writeStructBegin('Response')
    if self.items is not None:
      oprot.writeFieldBegin('items', TType.LIST, 1)
      oprot.writeListBegin(TType.STRUCT, len(self.items))
      for iter6 in self.items:
        iter6.write(oprot)
      oprot.writeListEnd()
      oprot.writeFieldEnd()
    oprot.writeFieldStop()
    oprot.writeStructEnd()

  def validate(self):
    if self.items is None:
      raise TProtocol.TProtocolException(message='Required field items is unset!')
    return


  def __hash__(self):
    value = 17
    value = (value * 31) ^ hash(self.items)
    return value

  def __repr__(self):
    L = ['%s=%r' % (key, getattr(self, key))
      for key in self.__slots__]
    return '%s(%s)' % (self.__class__.__name__, ', '.join(L))

  def __eq__(self, other):
    if not isinstance(other, self.__class__):
      return False
    for attr in self.__slots__:
      my_val = getattr(self, attr)
      other_val = getattr(other, attr)
      if my_val != other_val:
        return False
    return True

  def __ne__(self, other):
    return not (self == other)
```

> 服务化代码的实例 XxxService.py：

```python
from thrift.Thrift import TType, TMessageType, TException, TApplicationException
from .ttypes import *
from thrift.Thrift import TProcessor
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol, TProtocol
try:
  from thrift.protocol import fastbinary
except:
  fastbinary = None


class Iface(object):
  def retrieve(self, request):
    """
    Parameters:
     - request
    """
    pass


class Client(Iface):
  def __init__(self, iprot, oprot=None):
    self._iprot = self._oprot = iprot
    if oprot is not None:
      self._oprot = oprot
    self._seqid = 0

  def retrieve(self, request):
    """
    Parameters:
     - request
    """
    self.send_retrieve(request)
    return self.recv_retrieve()

  def send_retrieve(self, request):
    self._oprot.writeMessageBegin('retrieve', TMessageType.CALL, self._seqid)
    args = retrieve_args()
    args.request = request
    args.write(self._oprot)
    self._oprot.writeMessageEnd()
    self._oprot.trans.flush()

  def recv_retrieve(self):
    iprot = self._iprot
    (fname, mtype, rseqid) = iprot.readMessageBegin()
    if mtype == TMessageType.EXCEPTION:
      x = TApplicationException()
      x.read(iprot)
      iprot.readMessageEnd()
      raise x
    result = retrieve_result()
    result.read(iprot)
    iprot.readMessageEnd()
    if result.success is not None:
      return result.success
    if result.exc is not None:
      raise result.exc
    raise TApplicationException(TApplicationException.MISSING_RESULT, "retrieve failed: unknown result")


class Processor(Iface, TProcessor):
  def __init__(self, handler):
    self._handler = handler
    self._processMap = {}
    self._processMap["retrieve"] = Processor.process_retrieve

  def process(self, iprot, oprot):
    (name, type, seqid) = iprot.readMessageBegin()
    if name not in self._processMap:
      iprot.skip(TType.STRUCT)
      iprot.readMessageEnd()
      x = TApplicationException(TApplicationException.UNKNOWN_METHOD, 'Unknown function %s' % (name))
      oprot.writeMessageBegin(name, TMessageType.EXCEPTION, seqid)
      x.write(oprot)
      oprot.writeMessageEnd()
      oprot.trans.flush()
      return
    else:
      self._processMap[name](self, seqid, iprot, oprot)
    return True

  def process_retrieve(self, seqid, iprot, oprot):
    args = retrieve_args()
    args.read(iprot)
    iprot.readMessageEnd()
    result = retrieve_result()
    try:
      result.success = self._handler.retrieve(args.request)
    except malaita.thrift.errors.ttypes.MalaitaException as exc:
      result.exc = exc
    oprot.writeMessageBegin("retrieve", TMessageType.REPLY, seqid)
    result.write(oprot)
    oprot.writeMessageEnd()
    oprot.trans.flush()


# HELPER FUNCTIONS AND STRUCTURES

class retrieve_args(object):
  """
  Attributes:
   - request
  """

  __slots__ = [ 
    'request',
   ]

  thrift_spec = (
    None, # 0
    (1, TType.STRUCT, 'request', (Request, Request.thrift_spec), None, ), # 1
  )

  def __init__(self, request=None,):
    self.request = request

  def read(self, iprot):
    if iprot.__class__ == TBinaryProtocol.TBinaryProtocolAccelerated and isinstance(iprot.trans, TTransport.CReadableTransport) and self.thrift_spec is not None and fastbinary is not None:
      fastbinary.decode_binary(self, iprot.trans, (self.__class__, self.thrift_spec))
      return
    iprot.readStructBegin()
    while True:
      (fname, ftype, fid) = iprot.readFieldBegin()
      if ftype == TType.STOP:
        break
      if fid == 1:
        if ftype == TType.STRUCT:
          self.request = Request()
          self.request.read(iprot)
        else:
          iprot.skip(ftype)
      else:
        iprot.skip(ftype)
      iprot.readFieldEnd()
    iprot.readStructEnd()

  def write(self, oprot):
    if oprot.__class__ == TBinaryProtocol.TBinaryProtocolAccelerated and self.thrift_spec is not None and fastbinary is not None:
      oprot.trans.write(fastbinary.encode_binary(self, (self.__class__, self.thrift_spec)))
      return
    oprot.writeStructBegin('retrieve_args')
    if self.request is not None:
      oprot.writeFieldBegin('request', TType.STRUCT, 1)
      self.request.write(oprot)
      oprot.writeFieldEnd()
    oprot.writeFieldStop()
    oprot.writeStructEnd()

  def validate(self):
    return


  def __hash__(self):
    value = 17
    value = (value * 31) ^ hash(self.request)
    return value

  def __repr__(self):
    L = ['%s=%r' % (key, getattr(self, key))
      for key in self.__slots__]
    return '%s(%s)' % (self.__class__.__name__, ', '.join(L))

  def __eq__(self, other):
    if not isinstance(other, self.__class__):
      return False
    for attr in self.__slots__:
      my_val = getattr(self, attr)
      other_val = getattr(other, attr)
      if my_val != other_val:
        return False
    return True

  def __ne__(self, other):
    return not (self == other)


class retrieve_result(object):
  """
  Attributes:
   - success
   - exc
  """

  __slots__ = [ 
    'success',
    'exc',
   ]

  thrift_spec = (
    (0, TType.STRUCT, 'success', (Response, Response.thrift_spec), None, ), # 0
    (1, TType.STRUCT, 'exc', (malaita.thrift.errors.ttypes.MalaitaException, malaita.thrift.errors.ttypes.MalaitaException.thrift_spec), None, ), # 1
  )

  def __init__(self, success=None, exc=None,):
    self.success = success
    self.exc = exc

  def read(self, iprot):
    if iprot.__class__ == TBinaryProtocol.TBinaryProtocolAccelerated and isinstance(iprot.trans, TTransport.CReadableTransport) and self.thrift_spec is not None and fastbinary is not None:
      fastbinary.decode_binary(self, iprot.trans, (self.__class__, self.thrift_spec))
      return
    iprot.readStructBegin()
    while True:
      (fname, ftype, fid) = iprot.readFieldBegin()
      if ftype == TType.STOP:
        break
      if fid == 0:
        if ftype == TType.STRUCT:
          self.success = Response()
          self.success.read(iprot)
        else:
          iprot.skip(ftype)
      elif fid == 1:
        if ftype == TType.STRUCT:
          self.exc = malaita.thrift.errors.ttypes.MalaitaException()
          self.exc.read(iprot)
        else:
          iprot.skip(ftype)
      else:
        iprot.skip(ftype)
      iprot.readFieldEnd()
    iprot.readStructEnd()

  def write(self, oprot):
    if oprot.__class__ == TBinaryProtocol.TBinaryProtocolAccelerated and self.thrift_spec is not None and fastbinary is not None:
      oprot.trans.write(fastbinary.encode_binary(self, (self.__class__, self.thrift_spec)))
      return
    oprot.writeStructBegin('retrieve_result')
    if self.success is not None:
      oprot.writeFieldBegin('success', TType.STRUCT, 0)
      self.success.write(oprot)
      oprot.writeFieldEnd()
    if self.exc is not None:
      oprot.writeFieldBegin('exc', TType.STRUCT, 1)
      self.exc.write(oprot)
      oprot.writeFieldEnd()
    oprot.writeFieldStop()
    oprot.writeStructEnd()

  def validate(self):
    return


  def __hash__(self):
    value = 17
    value = (value * 31) ^ hash(self.success)
    value = (value * 31) ^ hash(self.exc)
    return value

  def __repr__(self):
    L = ['%s=%r' % (key, getattr(self, key))
      for key in self.__slots__]
    return '%s(%s)' % (self.__class__.__name__, ', '.join(L))

  def __eq__(self, other):
    if not isinstance(other, self.__class__):
      return False
    for attr in self.__slots__:
      my_val = getattr(self, attr)
      other_val = getattr(other, attr)
      if my_val != other_val:
        return False
    return True

  def __ne__(self, other):
    return not (self == other)
```

#### 3 Servers

TServer 的抽象如下：

+ 使用 TServerTransport 来获得一个 TTransport
+ 使用 TTransportFactory 来可选地将原始的传输转换为一个更适合应用的传输（Transport，比如 TBufferedTransportFactory）
+ 使用 TProtocalFactory 创建一个输入一个输出协议
+ 调用 TProcessor 的 process() 方法

各层之间完全解耦，服务器代码不需要知道任何 transport、encodings 和 application 的相关信息。Server 包括了连接操作的逻辑，线程。而 processor 主要处理
RPC。而应用开发者仅需要定义 Thrift 文件并实现其中的接口即可。

+ TSimpleServer: 一个简单的单线程服务器，使用标准的阻塞 IO，仅用于 testing。
+ TThreadPoolServer: 一个使用多线程实现的，使用标准阻塞 IO 的服务器。
+ TNonblockingServer: 使用非阻塞 IO 的多线程服务器（在 Java 实现中使用 NIO 通道） TFramedTransport 应当和这种服务器一起使用。

> 服务的启动

```python
import logging
import time
import signal
import logging.config

from malaita.thrift.services.recall.ttypes import Response, Item
from .utils import CFRecall
from malaita.events.tasks import cf_recall
import malaita.common.metrics as metrics
from malaita.common.db import ensure_session_removed
from anacapa.thrift.server.gevent import TGeventServer
from gevent.threadpool import ThreadPool
from malaita import app
from malaita.thrift.services.recall.RecallService import Iface, Processor
from malaita import db

CF_RECALL_LATENCY_KEY = "post.cf.latency"
metrics.define_timer(CF_RECALL_LATENCY_KEY)


class XxxService(Iface):

    def retrieve(self, request):

        st = time.time()
        response = Response()
        response.items = []
        try:
            item_ids = CFRecall(request.user_id)(request.count)
            # 增加事件记录
            # cf_recall.delay(request.user_id, item_ids)

            response.items = [Item(id=item_id) for item_id in item_ids]
        except Exception as e:
            logging.error("cf recall has exception : {0}".format(repr(e)))
        finally:
            metrics.emit_timer(CF_RECALL_LATENCY_KEY, 1000 * (time.time() - st))
            logging.info("cf recall items: {0}, user: {1}".format(item_ids, request.user_id))
            return response


class XxxProcessor(Processor):

    def __init__(self, handler):
        super().__init__(handler)
        pool = ThreadPool(10)
        old_retrieve = handler.retrieve

        def retrieve(*args, **kwargs):
            result = pool.spawn(ensure_session_removed(old_retrieve), *args, **kwargs)
            return result.get()

        handler.retrieve = retrieve

    def process(self, iprot, oprot):
        try:
            return super().process(iprot, oprot)
        finally:
            db.session.remove()


def main():
    logging.config.dictConfig(app.config['CF_POST_RECALL_SERVICE_LOG_CONFIG'])
    signal.signal(signal.SIGHUP, signal.SIG_DFL)
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    handler = XxxService()
    processor = XxxProcessor(handler)
    server = TGeventServer(('0.0.0.0', app.config['CF_POST_RECALL_SERVICE_PORT']), processor)
    server.serve_forever()


if __name__ == '__main__':
    main()
```

> TGeventServer 的实现

```python
import errno
import logging
import socket

from gevent.server import StreamServer
from thrift.protocol import TBinaryProtocol
from thrift.transport import TTransport
from thrift.transport.TTransport import TFileObjectTransport


class TGeventServer(StreamServer):
    """Thrift server based on StreamServer."""

    def __init__(self, address, processor, logger=None, **kwargs):
        StreamServer.__init__(self, address, self._process_socket, **kwargs)
        self.logger = logger if logger else logging.getLogger()
        self.processor = processor
        self.input_transport_factory = TTransport.TFramedTransportFactory()
        self.output_transport_factory = TTransport.TFramedTransportFactory()
        self.input_protocol_factory = TBinaryProtocol.TBinaryProtocolAcceleratedFactory()
        self.output_protocol_factory = TBinaryProtocol.TBinaryProtocolAcceleratedFactory()
        self.cnt = 0

    def _process_socket(self, client, address):
        """A greenlet for handling a single client."""
        self.cnt += 1

        self.logger.debug('connect: %s total= %s', address, self.cnt)

        transport = TFileObjectTransport(client.makefile('rwb'))
        itrans = self.input_transport_factory.getTransport(transport)
        otrans = self.output_transport_factory.getTransport(transport)
        iprot = self.input_protocol_factory.getProtocol(itrans)
        oprot = self.output_protocol_factory.getProtocol(otrans)
        try:
            while True:
                self.processor.process(iprot, oprot)
        except EOFError:
            pass
        except socket.error as ex:
            # we do not care disconnect error
            if ex.errno not in (errno.ECONNRESET, errno.EPIPE):
                self.logger.exception(
                    "caught exception while processing thrift request %s", type(ex))

        except Exception as ex:
            self.logger.exception(
                "caught exception while processing thrift request %s", type(ex))

        for trans in [itrans, otrans]:
            try:
                trans.close()
            except:
                pass

        self.cnt -= 1
        self.logger.debug('disconnect: %s total= %s', address, self.cnt)
```

### 6 实现细节
