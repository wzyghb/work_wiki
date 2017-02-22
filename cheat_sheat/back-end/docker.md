
## 参考资料

+ [docker 入门和实践](https://www.gitbook.com/book/hujb2000/docker-flow-evolution/details)
+ []()

目前项目中 docker 主要作为开发环境，以后也可能将服务迁移到公司使用 k8s 搭建的 服务平台上。
因为是微服务架构，因而使用了 docker-compose 作为编排工具。

本部分主要分为 docker、 docker-compose、 docker-swarm 等。最后总结了下最近看到的 docker 的原理。

## 待补充

+ `docker-compose`
+ `swarm`
+ `kubernetes`

## docker 主组件

### docker 命令

#### 管理命令

管理命令包括了其他命令，其他命令可以看做是管理命令的语法糖，提供了快速的调用方法。

+ `container` container 相关的命令
  - `attach`
  - `commit`
  - `cp`
  - `create`
  - `diff`
  - `exec`
  - `export`
  - `inspect`
  - `kill`
  - `logs`
  - `ls`
  - `pause`
  - `port`
  - `prune` 删除所有没有运行的 container
  - `rename`
  - `restart`
  - `rm`
  - `run`
  - `start`
  - `stats`
  - `stop`
  - `top` 显示 container 中运行的进程
   

+ `image`

+ `network`

+ `plugin`

+ `stack`

+ `swarm`

+ `system`

+ `volume`

+ `checkpoint`

+ `node`

#### 镜像管理

+ `images` 查看本机的镜像
  - `-a` 显示所有 images
  - `-f` 进行条件过滤
  - `-q` 只显示 numeric IDs

+ `build` 从 Dockerfile 构建镜像


+ `tag` 创建一个 `TARGET_IMAGE` 指向 `SOURCE_IMAGE`

+ `save` 将一个或者多个 images 报错到 tar 归档中，默认输出到 STDOUT

+ `load` 加载

+ `rmi` 删除指定镜像

+ `history` 显示容器的历史

#### 容器管理

镜像可以创建容器，容器的运行结果会得到保留。

+ `create` 创建一个镜像

+ `attach` 连接到一个运行的容器

+ `cp` 在本地文件系统和 docker 之间复制文件或者目录

+ `run` 从镜像创建容器

  + 常用选项
    - `-t` 选项让Docker分配一个伪终端(pseudo-tty)并绑定到容器的标准输入上
    - `-i` 让容器的标准输入保持打开
    - `-d` 让容器后台运行

  + 执行流程
    - 检查本地是否存在指定的镜像，不存在就从公有仓库下载
    - 利用镜像创建并启动一个容器
    - 分配一个文件系统，并在只读的镜像层外面挂载一层可读写层
    - 从宿主主机配置的网桥接口中桥接一个虚拟接口到容器中去
    - 从地址池配置一个 ip 地址给容器
    - 行用户指定的应用程序
    - 执行完毕后容器被终止

+ `exec` 运行

+ `ps` 查看容器
  + 常用选项
    - `-a` 查看本地的所有容器，包括没有运行的容器

+ `rm` 删除容器
  + 常用选项
    - `-f` 删除正在运行的容器

+ `logs`
  + 常用选项
    - `--tail=<xxx> <container-name>` 查看最近的日志，例子：`--tail=300`
    - `-f <container-name>` 将正在运行的 docker 的日志打印终端绑定到当前窗口

+ `start` 启动

+ `stop` 停止一个或者多个容器

+ `expose` 导出容器
  + 例子： `sudo docker export 7691a814370e > ubuntu.tar`

+ `import` 导入容器
  + 例子： `cat ubuntu.tar | sudo docker import - test/ubuntu:v1.0`

+ `kill` 杀死一个或者多个运行的容器

+ `pause` 暂停一个或者多个容器

+ `rename`

+ `restart` 重启一个或者多个 container

+ `port` 显示指定 container 的端口映射

+ `commit` 从 container 的更改创建一个新的镜像

#### docker hub 相关命令

+ `login` 登陆到一个 docker register

+ `logout` 从 docker register 退出

+ `search` 在 Docker Hub 中搜索 image

+ `pull` 拉取远程服务器的镜像

+ `push` 向 register 推送一个 image 或者 repository



#### 其他命令

+ `deploy` 部署

#### 常用组合命令

| 命令 | 说明 |
| :--- | :--- |
| docker rm $(docker ps -a -q) | 清理所有处于终止状态的容器 |
| docker-compose run --rm <container-name> bash | 临时打开一个用后即删的 container 并连接到 bash |
| docker exec -it <container-name> bash | 连接到一个运行中的 container |



### Dockerfile

#### Dockerfile 构成：

| 功能说明 | 关键字 |
| :--- | :--- |
| 基础镜像信息 | FROM |
| 维护者信息 | MAINTAINER |
| 镜像操作指令 | RUN ADD EXPOSE |
| 容器启动时执行指令 | CMD |

Dockerfile 中每一条指令都创建了Docker镜像中的一层

#### Dockerfile 关键字详细说明

| 关键字 | 说明 |
| :--- | :--- |
| # | 为注释 |
| FROM | 表示Docker以哪个镜像为基础来创建 |
| RUN | 会在docker创建时运行。将复杂的 run 命令分开为多行，可以使 Dockerfile 更加具备可读性 |
| ADD | 添加本地文件。 `ADD <src> <dest>` <src> 可以是 Dockerfile所在目录的一个相对路径;也可以是一个 URL;还可以是一个 tar 文件 (自动解压为目录) |
| COPY | `COPY <src> <dest>` 当使用本地目录为源目录时，推荐使用 COPY |
| EXPOSE | 向外部开放端口 |
| CMD | 命令为容器启动后运行的命令。每个 Dockerfile 只能有一条 CMD 命令。如果指定了 多条命令，只有最后一条会被执行 |
| ENV | `ENV <key> <value>` 指定一个环境变量，会被后续 RUN 指令使用， 并在容器运行时保持 |
| ENTRYPOINT | 配置容器启动后执行的命令，并且不可被 docker run 提供的参数覆盖 |
| VOLUME | VOLUME ["/data"] 创建一个可以从本地主机或其他容器挂载的挂载点，一般用来存放数据库和需要保持的数据等 |
| USER | USER daemon 指定运行容器时的用户名或 UID，后续的 RUN 也会使用指定用户。要临时获取管理员权限可以使用 gosu，不推荐使用 sudo |
| WORKDIR | /path/to/workdir 为后续的 RUN 、 CMD 、 ENTRYPOINT 指令配置工作目录 |
| ONBUILD | |

## compose 组件


## swarm

Docker swarm 是一套管理 Docker 集群的工具。可以将一群 Docker 宿主机变成一个单一的虚拟主机。

> docker daemon: docker 最核心的后台进程，负责响应来自 Docker client的请求，然后将这些请求翻译成系统调用完成容器的管理。该
> 进程在后台启动一个 API Server，负责接收由 Docker client 发送的请求，接收到的请求将通过 Docker daemon 内部的一个路由分发调度，
> 再由具体的函数来执行请求。

### 准备
首先要把集群中所有节点的 docker daemon 监听方式指定为 `0.0.0.0:2375`。

1. 启动 docker daemon 时指定：

```bash
docker -H 0.0.0.0:2375&
```
2. 修改配置文件，ubuntu 下是：

在 /etc/default/docker 文件最后添加：

```bash
DOCKER_OPTS="-H 0.0.0.0:2375 -H unix:///var/run/docker.sock"
```

完成上述配置后，重启 docker：
```bash
sudo service docker restart
```
### 服务发现

docker 集群管理需要使用服务发现（Discovery service backend）Swarm 支持以下几种方式：
+ DockerHub 提供的服务发现
+ 本地的文件
+ etcd
+ consul
+ zookeeper
+ ip 地址列表

#### DockerHub 上的服务发现

集群由三个节点组成，机器分别为 `83`, `84`, `124`

+ 获取 token：
  - 在任意一台机器上运行 `docker run --rm swarm create` 
  - 返回全球唯一的 token `b7625e5a7a2dc7f8c4faacf2b510078e`，记住这个 token，会在后面加入集群时使用。
+ 加入集群： 
  - 在要加入集群的节点（如 `83`）上执行 `docker run -d swarm join --addr=ip_address:2375 token://token_id`
  - `-d` 参数启动了一个容器，使得对应的机器加入了集群，如果这个容器被停止或者删除，则这台机器就会从集群中退出。
  - 要让其他机器也加入集群，和上面的方式类似。
+ 启动 swarm manager 管理集群：
  - 如果需要 `83` 作为 swarm 管理节点，所以需要在 `83` 上执行 swarm


## 原理

### docker 在操作系统中的隔离
+ Namespaces 隔离的第一级，确保每一个容器中运行一个进程，而不影响容器以外的其他进程
+ Control Groups 是 LXC 的重要组成部分，具有资源核算与限制的关键功能
+ UnionFS 容器的构建块，支持 Docker 的轻量级以及快速性，构建了用户层

## 坑

### 加入验证

在使用公司的 docker 源时，遇到以下的问题：

```
ERROR: Get https://hub.xxxx.org/v1/_ping: x509: certificate signed by unknown authority
```

发现在 `/etc/docker/certs.d/hub.xxxx.org` 下设置 ca.crt 对 docker for mac 不生效。实际上只需要在以下设置即可：

`docker -> Preferences -> Daemon -> Basic -> Insecure registries`
下增加 `hub.xxxx.org`。
