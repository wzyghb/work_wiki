
## 基本命令


### 镜像

+ docker pull 
+ docker images
+ docker commit

Dockerfile 中每一条指令都创建了Docker镜像中的一层
+ `#` 为注释
+ FROM 表示Docker以哪个镜像为基础来创建。
+ RUN 会在docker创建时运行。
+ ADD 添加本地文件。
+ EXPOSE 向外部开放端口。
+ CMD命令为容器启动后运行的命令。

编写Dockerfile完成后可以使用：

+ docker build  来创建镜像。上面的步骤中每一次RUN都会创建一个Container，然后下一次创建前会删除中间的Container。完成镜像的创建过程后，就可以在在docker中启动这个容器。
+ docker tag 
+ docker save 导出到本地文件
+ docekr load 从本地文件加载到本地镜像库
+ docker rmi 移除本地镜像 移除镜像前要用docker rm删除所有依赖的本地容器
+ docker rm 移除本地容器

### 容器

+ docker run xxx
+ docker run -d xxx
+ docker ps xxx
+ docker logs --tail=1000 xxx
+ docker logs -f xxx

+ docker start xxx
+ docker stop xxx
+ docker attach

### docker 在操作系统中的隔离
+ Namespaces 隔离的第一级，确保每一个容器中运行一个进程，而不影响容器以外的其他进程
+ Control Groups 是 LXC 的重要组成部分，具有资源核算与限制的关键功能
+ UnionFS 容器的构建块，支持 Docker 的轻量级以及快速性，构建了用户层


## Dockerfile 最佳实践
### 1 基本命令

+ FROM
+ RUN 将复杂的 run 命令分开为多行，可以使 Dockerfile 更加具备可读性。
+ apt-get 
+ CMD
+ EXPOSE
+ ENV
+ ADD or COPY
+ ENTRYPOINT
+ VOLUME
+ USER
+ WORKDIR
+ ONBUILD

## 示例

### 1 scala-sbt

```Dockerfile
# Pull base image
FROM java:8

ENV SCALA_VERSION 2.11.8
ENV SBT_VERSION 0.13.12

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala-$SCALA_VERSION/bin:$PATH' >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb http://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion
```

### 2 