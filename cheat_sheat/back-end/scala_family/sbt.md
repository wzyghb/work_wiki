
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

## 附加说明

+ `build.properties` 中附加强制使用的 sbt 版本：`sbt.version = 0.13.5`
+ 构建结果会保存到的 `target\` 的文件中。
+ 