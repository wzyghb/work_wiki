
## Style Guide

### Message 和 Field 的名字
使用 CamelCase 来命名 Message 名称，使用 下划线来分割 Field name 的单词。

```
message SongServerRequest {
    required string song_name = 1;
}
```

### Enums 
使用  CamelCase 来命名 enum type 的名字，使用大写加下划线的方式来命名 enum 中的值。
```
enum FooCase {
    FIRST_VALUE = 1;
    SECOND_VALUE = 2;
}
```

### Services
使用 CamelCase 命名 RPC Service 以及所有的 RPC 方法名称。

```
Service FooService {
    rpc GetSomething(FooRequest) returns (FooResponse);
}
```

## 基本流程

1. 在 proto 中定义消息格式
2. 使用 proto buffer 的编译器进行编译
3. 安装 protobuf 库
4. 使用 Python 的 protocol buffer API 来读写消息

## 基本概念

+ scalar types
+ enumerations
+ unique numbered tag ：在消息的二进制格式中标识域。
+ reserved field: 当要删掉一个域时可以声明为 reserved，避免以后的人使用对应的 tag， 从而产生问题


## 注意

+ tags 的值为 1 到 15 时，需要 1 byte 来进行编码（包括标识数字和域的类型）而 16 到 2047 个 tag 则每个需要 2 个字节来标识。因而最好把常用的 tag 编小。并给可能的常用的域留好空位。
+ repeated 修饰的 scalar numeric 类型并没有能够很高效地进行编码。可以使用选项使其更加高效地编码： `repeated int32 samples = 4 [packed=true];`
+ 

## 例子

```proto
//
package tutorial;

message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    required string number = 1;
    optional PhoneType type = 2 [default = HOME];
  }

  repeated PhoneNumber phone = 4;
}

message AddressBook {
  repeated Person person = 1;
}

message Foo {
  reserved 2, 15, 9 to 11;
  reserved "foo", "bar";
}
```

尽量减少 required 字段的使用。

```
import addressbook_pb2
person = addressbook_pb2.Person()
person.id = 1234
person.name = "John Doe"
person.email = "jdoe@example.com"
phone = person.phone.add()
phone.number = "555-4321"
phone.type = addressbook_pb2.Person.HOME
```

错误处理：

```
person.no_such_field = 1  # raises AttributeError
person.id = "1234"        # raises TypeError
```

enum 类型的值不能超过 `2^32`, 也可以有别名，表示如下：

```
enum EnumAllowingAlias {
  option allow_alias = true;
  UNKNOWN = 0;
  STARTED = 1;
  RUNNING = 1;
}
```

可以在一个 message 的定义中使用另一 message 的定义。导入定义：

```
import "myproject/other_protos.proto";
import public "new.proto"
```

import 和 import public 的区别。

### Nested Type

```
message SearchResponse {
  message Result {
    required string url = 1;
    optional string title = 2;
    repeated string snippets = 3;
  }
  repeated Result result = 1;
}

message SomeOtherMessage {
  optional SearchResponse.Result result = 1;
}

message Outer {                  // Level 0
  message MiddleAA {  // Level 1
    message Inner {   // Level 2
      required int64 ival = 1;
      optional bool  booly = 2;
    }
  }
  message MiddleBB {  // Level 1
    message Inner {   // Level 2
      required int32 ival = 1;
      optional bool  booly = 2;
    }
  }
}


```

### 扩展 Extensions

```
message Foo {
  // ...
  extensions 100 to 199;
}

extend Foo {
  optional int32 bar = 126;
}
```

+ SetExtension
+ HasExtension
+ ClearExtension
+ GetExtension
+ MutableExtension
+ AddExtension

### Oneof
定义如下：
```
message SampleMessage {
  oneof test_oneof {
     string name = 4;
     SubMessage sub_message = 9;
  }
}
```

+ 多次设置，仅会有最后一次生效
+ 如果在 wire 上遇到多个相同的 oneof 值，仅有最后一个值会在 parse 的结果中生效
+ Extension 不支持 oneof
+ oneof 不支持 repeated
+ reflection api 可以在 oneof 域中生效

### Map
创建 Map 的快捷语法如下：
```
map<K, V> map_field = N;
```
K 可以是 integral 或者 string 或者任意的 scalar 类型，不能是 floating point 类型和 bytes。

#### Map 的特点
+ 扩展不支持 map
+ map 不能够 repeated、optional 或者 required
+ map 内部的 value 是不确定的，代码不能依赖于 map 中数值的特定的顺序
+ 在转化为 text 格式时，maps 会以 key 为顺序进行排序。
+ 当进行 merging 或者从 wire 进行 parse 时，若有重复的 map key，那么最后一个会有效，当从 text 格式解析时，若有重复的 key，会报错。
+ 当在 wire 上时， map 类型实际上是重复 repeated 的键值对。




## 更新消息类型的基本原则

+ 不要改变已经存在域的 tag 值。
+ 所有添加的新 field 应该是 optional 或者 repeated 的。
+ 不再需要的 field 应该被 reserved， 
+ int32、uint32、int64、uint64 和 bool 都是可兼容的。
+ sint32、sint64 也是相互兼容的。
+ string 和 bytes 也是相互兼容的，如果 bytes 是合法的 utf-8
+ fixed32 和 sfixed32、fixed64 和 sfixed64 都是兼容的
+ optional 和 repeated 是相互兼容的
+ 默认值永远不会在网络上传输。
+ enum 和 int32、uint32、int64、uint64 相互兼容。
