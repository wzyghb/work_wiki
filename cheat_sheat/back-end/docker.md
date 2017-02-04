
## 基本命令


### 镜像

#### docker pull 

例子：

```
sudo docker pull ubuntu:12.04
sudo docker pull dl.dockerpool.com:5000/ubuntu:12.04
```

#### docker images
列出本机的所有 image。

#### 

#### docker commit 修改已有的镜像
将构建好的容器导出为镜像存储下来。

docker 的修改和 提交:

```
sudo docker run -t -i training/sinatra /bin/bash
sudo docker commit -m "Added json gem" -a "Docker Newbee" 0b2616b0e5a8 ouruser/sinatra:v2
```
+ -m：提交的说明信息
+ -a：指定更新的用户信息
+ 创建镜像容器的 ID
+ 指定目标镜像的仓库名和 tag 信息

#### Dockerfile

Dockerfile 由四部分构成：

+ 基础镜像信息 FROM
+ 维护者信息 MAINTAINER
+ 镜像操作指令  RUN ADD EXPOSE
+ 容器启动时执行指令 CMD


Dockerfile 中每一条指令都创建了Docker镜像中的一层
+ `#` 为注释
+ FROM 表示Docker以哪个镜像为基础来创建。
+ RUN 会在docker创建时运行。
+ ADD 添加本地文件。 `ADD <src> <dest>` <src> 可以是 Dockerfile所在目录的一个相对路径;也可以是一个 URL;还可以是一个 tar 文件 (自动解压为目录)
+ COPY `COPY <src> <dest>` 当使用本地目录为源目录时，推荐使用 COPY。
+ EXPOSE 向外部开放端口。
+ CMD命令为容器启动后运行的命令。每个 Dockerfile 只能有一条 CMD 命令。如果指定了 多条命令，只有最后一条会被执行
+ ENV `ENV <key> <value>` 指定一个环境变量，会被后续 RUN 指令使用， 并在容器运行时保持
+ ENTRYPOINT 配置容器启动后执行的命令，并且不可被 docker run 提供的参数覆盖
+ VOLUME VOLUME ["/data"] 创建一个可以从本地主机或其他容器挂载的挂载点，一般用来存放数据库和需要保持的数据等。
+ USER USER daemon 指定运行容器时的用户名或 UID，后续的 RUN 也会使用指定用户。要临时获取管理员权限可以使用 gosu，不推荐使用 sudo。
+ WORKDIR /path/to/workdir 为后续的 RUN 、 CMD 、 ENTRYPOINT 指令配置工作目录
编写Dockerfile完成后可以使用：

+ docker build  来创建镜像。上面的步骤中每一次RUN都会创建一个Container，然后下一次创建前会删除中间的Container。完成镜像的创建过程后，就可以在在docker中启动这个容器。
+ docker tag 
+ docker save 导出到本地文件 `sudo docker save -o ubuntu_14.04.tar ubuntu:14.04`
+ docekr load 从本地文件加载到本地镜像库
+ docker rmi 移除本地镜像 移除镜像前要用docker rm删除所有依赖的本地容器

### 容器

镜像可以创建容器，容器的运行结果会得到保留。

#### docker run xxx 从镜像创建容器 run 命令
```
sudo docker run -t -i ubuntu:12.04 /bin/bash
```
+ docker run 选项
  + -t 选项让Docker分配一个伪终端(pseudo-tty)并绑定到容器的标准输入上
  + -i 让容器的标准输入保持打开

+ docker run 流程
    - 检查本地是否存在指定的镜像，不存在就从公有仓库下载
    - 利用镜像创建并启动一个容器
    - 分配一个文件系统，并在只读的镜像层外面挂载一层可读写层
    - 从宿主主机配置的网桥接口中桥接一个虚拟接口到容器中去
    - 从地址池配置一个 ip 地址给容器
    - 行用户指定的应用程序
    - 执行完毕后容器被终止

+ docker run -d 后台运行

容器启动后进入后台，但是有时候又需要进入容器进行操作，可以使用下面的命令：
+ docker attach <name> 当多个窗口同时 attach 到同一个容器的 时候，所有窗口都会同步显示，因而是有问题的
+ nsenter

#### 查看容器
docker ps xxx
#### 容器中的日志记录
+ docker logs --tail=1000 xxx
+ docker logs -f xxx

#### 容器的启动和终止
+ docker start xxx 启动已经终止的容器
+ docker stop xxx 

#### 导入和导出容器

+ sudo docker export 7691a814370e > ubuntu.tar
+ cat ubuntu.tar | sudo docker import - test/ubuntu:v1.0

#### 删除容器

+ docker rm 
    + -f 删除正在运行的容器
+ docker rm $(docker ps -a -q) 清理所ß有处于终止状态的容器

## docker 中的网络

### 外部访问容器
创建容器时使用 -p / -P 参数来指定端口映射。

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