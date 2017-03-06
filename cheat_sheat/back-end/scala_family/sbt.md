
## 源代码目录

```
\<project_name>
  \src\main\scala\
           \java\
           \resource\
  \src\test\scala\
           \java\
           \resource\
  \lib\
  \project\Build.scala
          \build.properties
  build.sbt
```

## 最简单的 `build.sbt`

```scala
resolvers ++= Seq(
  "Typesafe Repository" at "http://repo.typesafe.com/typesafe/releases/"
)

lazy val root = (project in file("."))
  .settings(
    name := "xxxx",
    scalaVersion := "2.11.8",
    libraryDependencies ++= Seq(
      "junit" % "junit" % "4.11" % "test",
      "org.scalatest" %% "scalatest" % "2.2.6" % "test"
    )
  )
```

## 基本命令

+ `compile`
+ `run` 运行
+ `~compile` 自动触发编译和运行过程
+ `clean` 清除 target 下的 `resolution-cache` 和 `scala-2.11`
+ `test`
+ `console` 启动一个 Scala 语言交互模式，`:quit` `Ctrl + D` `Ctrl + Z` 返回到 sbt
+ `package` 将 `scala-2.11` 的 class 文件打包为 `<name>_2.xx-version-SNAPSHOT.jar`
+ `help`
+ `reload` 重载配置文件，包括 `build.sbt` `project\*.scala` `project\*.sbt`
+ `!` 历史命令相关 `!!` `!:` `!:n` `!n` `!-n` `!<str>` `!?<str>`

## 构建语句
 
sbt 以一个 map 来描述构建过程，如上面的例子中，如果在 sbt 命令行中敲入 `name`, 则会输出 `xxxx`。
而 `name := "hello"` 实际上定义了一个 `Setting[String]` 类型的配置项。 sbt 中的 keys 可以有以下几种类型：

+ `SettingKey[T]` 只计算一次，会在完成后保留值
+ `TaskKey[T]`  会做为调用任务，每次使用都会重新计算，也会产生影响
+ `InputKey[T]`  这类 key 针对一个任务需要传递一些输入参数

自定义 keys 的例子:

```scala
import sbt.keys._

lazy val hello = TaskKey[Unit]("an example key")
```

配置 keys：

```scala
// task
hello := {println("hello")}

// settings
name := "hello"
```

## 深入 keys

### 作用域的维度

+ 项目维度
+ 配置维度
+ 任务维度

### sbt 中的配置维度
+ `Compile` 定义编译项目配置 `src\main\scala\`
+ `Test` 定义测试项目的配置  `src\test\scala\`
+ `Runtime` 定义运行一个工程时的配置

在构建工程中定义多个项目，每个项目有自己唯一的配置，这时 key 的作用域是一个具有项目维度的作用域。


## 附加说明

+ `build.properties` 中附加强制使用的 sbt 版本：`sbt.version = 0.13.5`
+ 构建结果会保存到的 `target\` 的文件中。
+ 