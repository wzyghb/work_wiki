
## 参考资料

+ [docker 最佳实践](https://www.gitbook.com/book/hujb2000/docker-flow-evolution/details)
+ [docker 入门和实践](https://www.gitbook.com/book/yeasy/docker_practice)

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
  - `build`
  - `history`
  - `import`
  - `inspect`
  - `load`
  - `ls`
  - `prune`
  - `pull`
  - `push`
  - `rm`
  - `save` 和 `load` 相对应，将 image 存储为 tar 格式的文件。
  - `tag`

+ `network`
  - `connect [OPTIONS] NETWORK CONTAINER`
  - `create`
  - `disconnect`
  - `inspect`  显示一个或者多个网络的详细信息
  - `ls`  列表展示所有网络
  - `prune`  删除没有使用的网络
  - `rm`  删除一个或者多个网络

+ `plugin` 这个还没有用过
  - `create`
  - `disable`
  - `enable`
  - `install`
  - `inspect`
  - `ls`
  - `push`
  - `rm`
  - `set`
  - `upgrade`

+ `stack` 和 swarm 相关的命令
  - `deploy`
  - `ls`
  - `ps`
  - `rm`
  - `services`

+ `swarm` 
  - `init`  初始化
  - `join`  作为 node 或者 manager 加入到 swarm
  - `join-token`  管理 join token
  - `leave`  离开 swarm
  - `unlock`  
  - `unlock-key`
  - `update`  

+ `system`
  - `df`  显示 docker 对硬盘的使用
  - `events`  从服务器获得实时的事件
  - `info`  显示系统层级的信息
  - `prune`  删除无用数据

+ `volume`
  - `create`  创建一个卷
  - `inspect`  显示一个或者多个卷的细节
  - `ls`  列表显示所有的卷
  - `prune`  删除所有没有使用的卷
  - `rm`  删除一个或者多个卷

+ `checkpoint`
  - `create`  创建一个 checkpoint
  - `ls`  列表显示一个 container 的 checkpoint
  - `rm`  删除一个 checkpoint
> 创建的 checkpoint 可以使用 `docker start` 命令启动，从而将状态 restore 回来。

+ `node` 管理 swarm 的 node
  - `demote`  降级 swarm 中的一个或者多个 manager 节点
  - `inspect`  显示一个或者多个 node 的详细信息
  - `ls`  显示 swarm 中的节点列表
  - `promote`  将 swarm 中的一个或者多个节点提升为 manager
  - `ps`  列表展示在一个或者多个节点上运行的任务，默认显示当前节点的任务
  - `rm`  在 swarm 中删除一个或者多个 node
  - `update`  更新一个 node

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
  - `-a`  连接到 STDOUT/STDERR 并输出一个 signal
  - `--checkpoint <string>`  从 checkpoint restore
  - `--checkpoint-dir <string>`  使用自定义的 checkpoint 存储目录
  - `-i`  连接到 container 的 STDIN

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
| `docker rm $(docker ps -a -q)` | 清理所有处于终止状态的容器 |
| `docker-compose run --rm <container-name> bash` | 临时打开一个用后即删的 container 并连接到 bash |
| `docker-compose down -v` | 停止并删除 docker-compose.yml 定义的文件 |
| `docker exec -it <container-name> bash` | 连接到一个运行中的 container |



### Dockerfile

#### Dockerfile 关键字详细说明

| 关键字 | 说明 |
| :--- | :--- |
| `#` | 为注释 |
| `FROM` | 表示Docker以哪个镜像为基础来创建 |
| `RUN` | 会在docker创建时运行。将复杂的 run 命令分开为多行，可以使 Dockerfile 更加具备可读性 |
| `ADD` | 添加本地文件。 `ADD <src> <dest>` <src> 可以是 Dockerfile所在目录的一个相对路径; 也可以是一个 URL;还可以是一个 tar 文件 (自动解压为目录) 就是一个 比 Copy 更高级的复制命令 |
| `COPY` | `COPY <src> <dest>` 当使用本地目录为源目录时，推荐使用 `COPY` |
| `EXPOSE` | 向外部开放端口 |
| `CMD` | 命令为容器启动后运行的命令。每个 Dockerfile 只能有一条 `CMD` 命令。如果指定了 多条命令，只有最后一条会被执行 |
| `ENV` | `ENV <key> <value>` 指定一个环境变量，会被后续 RUN 指令使用， 并在容器运行时保持 |
| `ENTRYPOINT` | 配置容器启动后执行的命令，并且不可被 `docker run` 提供的参数覆盖 |
| `VOLUME` | `VOLUME` `["/data"]` 创建一个可以从本地主机或其他容器挂载的挂载点，一般用来存放数据库和需要保持的数据等 |
| `USER` | `USER daemon` 指定运行容器时的用户名或 `UID`，后续的 `RUN` 也会使用指定用户。要临时获取管理员权限可以使用 `gosu`，不推荐使用 `sudo` |
| `WORKDIR` | `/path/to/workdir` 为后续的 `RUN` 、 `CMD` 、 `ENTRYPOINT` 指令配置工作目录 |
| `ONBUILD` | |

## compose 组件

用 python 编写的 docker 项目编排管理工具。调用 docker 服务的 api 实现了对容器的管理。

### 基本概念
+ 服务(service)： 应用的容器，实际上可以包括若干运行相同镜像的容器实例
+ 项目(project)：由一组关联的应用容器组成的业务单元

### docker-compose命令

基本形式：

```
docker-compose [-f=<arg>...] [options] [COMMAND] [ARGS...]
```
#### 命令选项

+ `-f`, `--file` `FILE` 指定使用的 compose 模板文件，默认为 docker-compose.yml
+ `-p`, `--project-name` `NAME` 指定项目名称，默认将使用所在目录名称作为项目名
+ `--x-networking` 使用 docker 的可插拔网络后端特性
+ `--x-networking-driver DRIVER` 指定网络后端的驱动，默认为 `bridge`
+ `--verbose` 输出更多调试信息
+ `-v, --version` 打印版本并退出

#### 命令使用说明

+ `build` 构建、重新构建项目中的容器
  - `--force-rm`  删除构建过程中的临时容器
  - `--no-cache`  构建过程中不适用 cache
  - `--pull`  尝试使用 pull 来获取更新的版本镜像

+ `help` 
+ `kill` 发送 `SIGKILL` 信号来强制停止服务容器
  - `-s`  指定发送的信号
+ `logs`
+ `pause`
+ `port`
+ `ps`
+ `pull`  拉取服务依赖的镜像
+ `restart`  重启项目中的服务
+ `rm`  删除所有处于停止状态服务的容器
+ `run`  在指定的服务上执行一个命令
  - `docker-compose run [options] [-p PORT...] [-e KEY=VAL...] SERVICE [COMMAND] [ARGS...]`
  - 给定命令会自动覆盖原有的自动运行命令
  - 不会自动创建端口，以避免冲突
+ `scale` 设置指定容器运行的容器的个数
  - `docker-compose scale [options] [SERVICE=NUM...]`
  - 当指定的数目多于该服务当前运行的容器时，会创建并启动容器，反之，会停止容器。
+ `start`
+ `stop`
+ `unpause`  恢复处于暂停状态中的服务。
+ `up`  组合命令，依次尝试：构建镜像、创建服务、启动服务、关联服务相关容器等一系列操作
  - 默认启动的容器都处于前台，`Ctrl-C` 停止命令时，所有容器会停止
  - `-d`  在后台运行服务容器
  - `--no-color` 不使用颜色来区分不同服务的控制台输出
  - `--no-deps`  不启动服务所链接的容器
  - `--force-recreate`  强制重新创建容器
  - `--no-recreate`  如果容器已经存在，则不重新创建容器
  - `--no-build`  不自动构建确实的服务镜像
  - `-t, --timeout TIMEOUT`  停止容器时候的超时 （默认为 10 秒）
+ `version`

#### 模板文件中的命令

+ `build` 指定 Dockerfile 所在文件夹的路径
+ `cap_add` 增加内核分配能力
+ `cap_drop` 删除内核分配能力
+ `command` 覆盖容器启动后默认执行的命令
+ `cgroup_parent`
+ `container_name` 指定容器的名称，默认会使用 `项目名称_服务名称_序号` 的格式进行命名，增加这个参数后，将无法自动扩展
+ `devices` 
+ `dns`  自定义 DNS 列表，可以是一个值，也可以是一个列表。
+ `dns_search`  配置 DNS 搜索域，可以是一个值，也可以是一个列表。
+ `dockerfile`  指定额外的编译镜像的 Dockerfile 文件。
+ `env_file` 从文件中获取环境变量
+ `environment`  设置环境变量，如果只给定名字，会自动获取 Compose 主机上对应变量的值，防止数据泄露
+ `expose` 暴露端口，但不映射到宿主主机，只被连接的服务访问。
+ `extends` 基于其他的模板文件进行扩展。
+ `external_links`  链接到 docker-compose.yml 外部的容器，甚至并非 Compose 管理的容器。
+ `extra_hosts`  指定额外的 host 名称映射信息
+ `image`  指定镜像名称或者 id，如果不存在 compose 会尝试拉取这个镜像
+ `labels`  为 docker 镜像添加元数据 (metadata) 信息
+ `links`  链接到其他服务中的容器，使用 `服务名称` 或者 `服务名称:服务别名`
+ `log_driver` 
+ `log_opt`
+ `net`
+ `pid`  跟主机系统共享进程命名空间
+ `ports`  暴露端口信息，容器 (HOST:CONTAINER)。
+ `security_opt`
+ `ulimits`
+ `volumes`  数据卷挂载路径设置，可以摄住宿主机路径 (HOST:CONTAINER:访问模式)
+ `volumes_driver`
+ `volumes_from`  从另一个服务或者容器挂载它的数据卷

## swarm

Docker swarm 是一套管理 Docker 集群的工具。可以将一群 Docker 宿主机变成一个单一的虚拟主机。

+ `swarm manager`
+ `swarm node`
+ `swarm daemon`
  - `scheduler`
  - `router`
+ `discovery service`


> docker daemon: docker 最核心的后台进程，负责响应来自 Docker client的请求，然后将这些请求翻译成系统调用完成容器的管理。该
> 进程在后台启动一个 API Server，负责接收由 Docker client 发送的请求，接收到的请求将通过 Docker daemon 内部的一个路由分发调度，
> 再由具体的函数来执行请求。

注意点：
+ 集群中每台节点的 docker 版本不小于 1.4
+ 为了让 swarm manager 能够和每台 swarm node 进行通讯，集群中的每台结点的 Docker daemon 都必须监听同一个网络接口。

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


### swarm 调度策略

目前 swarm 启动 container 时，swarm 会根据选择的调度策略来选择节点运行 container。目前有的调度策略有：
+ spread 选择一个正在运行的container的数量最少的那个节点来运行container -> 有节点坏掉不会损失太多的 container
+ binpack 尽可能的把所有的容器放在一台节点上面运行 -> 避免容器碎片化，使用最少的节点运行最多的容器。
+ random


### swarm 过滤器

swarm 的调度器 (scheduler) 在选择节点运行容器的时候支持几种过滤器：
+ Constraint 启动 docker-daemon 时指定标签，然后就可以指定 container 运行的节点了
+ Affinity 使一个容器紧挨另一个容器运行
+ Port Filter Port 会是唯一资源，这样会使之后所有使用 80 端口的容器都启动失败
+ Dependency
+ Health

## Kubernetes
支持常见的云平台，支持内部的数据中心。

核心概念：`Container Pod` 容器仓，每个 Pod 是由一组工作于同一物理工作节点的容器构成的。这些容器拥有相同的网络
命名空间 VIP 以及存储配额，可以根据实际情况对每一个 Pod 进行端口映射。

## 原理

### docker 在操作系统中的隔离
+ Namespaces 隔离的第一级，确保每一个容器中运行一个进程，而不影响容器以外的其他进程
+ Control Groups 是 LXC 的重要组成部分，具有资源核算与限制的关键功能
+ UnionFS 容器的构建块，支持 Docker 的轻量级以及快速性，构建了用户层

### docker 中的网络
Docker 启动时，会在主机上创建一个 `docker0` 虚拟网桥，实际上是 linux 的bridge，可以理解为一个软件交换机。
他会在挂载到他的网口之间进行转发。


## 坑

### 加入验证

在使用公司的 docker 源时，遇到以下的问题：

```
ERROR: Get https://hub.xxxx.org/v1/_ping: x509: certificate signed by unknown authority
```

发现在 `/etc/docker/certs.d/hub.xxxx.org` 下设置 ca.crt 对 docker for mac 不生效。实际上只需要在以下设置即可：

`docker -> Preferences -> Daemon -> Basic -> Insecure registries`
下增加 `hub.xxxx.org`。


# etcd

+ 简单：支持 REST 风格的 HTTP+JSON API
+ 安全：支持 HTTPS 方式的访问
+ 快速：支持并发 1k/s 的写操作
+ 可靠：支持分布式结构，基于 Raft 的一致性算法
