
# Reflection 反射

程序检查甚至修改自身。
+ Compile-time Reflection
+ runtime reflection

## 1 runtiming reflection

主要内容：
+ 获得对象的类型信息，包括泛型信息
+ 实例化一个新的对象
+ 访问或者调用对象的的成员

### Example

#### 1 Inspecting a Runtime Type (Including Generic Types at Runtime)

`TypeTag` 是一种在运行时携带类型信息的对象。注意，`TypeTag` 在编译的时候产生，并携带到运行时。只有隐式的参数需要一个 `TypeTag` 时，编译器才会生成对应
的 `TypeTag` 。这也意味着，只能通过隐式的参数或者上下文界限来获得 `TypeTag` 信息。

```scala
import scala.reflect.runtime.{universe => ru}           // 为了使用 TypeTag 必须导入
val l = List(1,2,3)
def getTypeTag[T: ru.TypeTag](obj: T) = ru.typeTag[T]   // 拥有 context bound 的类型参数 T，使得编译器会给 T 定义 TypeTag
//  implicit “evidence” parameter

val theType = getTypeTag(l).tpe

// theType: ru.Type = List[Int]

val decls = theType.declarations.take(10)

// decls: Iterable[ru.Symbol] = List(constructor List, method companion, method isEmpty, method head, method tail, 
//      method ::, method :::, method reverse_:::, method mapConserve, method ++)
case class Person(name: String)
val m = ru.runtimeMirror(getClass.getClassLoader) // m 可以获取由当前类加载器加载的所有类

val classPerson = ru.typeOf[Person].typeSymbol.asClass
val cm = m.reflectClass(classPerson)
val ctor = ru.typeOf[Person].declaration(ru.nme.CONSTRUCTOR).asMethod
val ctorm = cm.reflectConstructor(ctor)
val p = ctorm("Mike")
```



#### 2 Instantiating a Type at Runtime

## 2 compile-time reflection

