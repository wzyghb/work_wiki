
目前项目中 docker 主要作为开发环境，以后也可能将服务迁移到公司使用 k8s 搭建的 服务平台上。
因为是微服务架构，因而使用了 docker-compose 作为编排工具。
本部分主要分为 docker 和 docker-compose 两部分。最后总结了下最近看到的 docker 的原理。

## docker

### docker 命令

#### 镜像管理

+ `images`

+ `pull`

+ `build`

+ `commit`

+ `tag`

+ `save`

+ `load`

+ `rmi`

#### 容器管理

镜像可以创建容器，容器的运行结果会得到保留。

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

+ `exec`

+ `ps` 查看容器

  + 常用选项
    - `-a` 查看本地的所有容器，包括没有运行的容器

+ `rm`

  + 常用选项
    - `-f` 删除正在运行的容器

+ `logs`
  
  + 常用选项
    - `--tail <container-name>` 查看最近的日志，例子：`--tail=300`
    - `-f <container-name>` 将正在运行的 docker 的日志打印终端绑定到当前窗口

+ `start`

+ `stop`

+ `expose` 导出容器

  + 例子： `sudo docker export 7691a814370e > ubuntu.tar`

+ `import` 导入容器

  + 例子： `cat ubuntu.tar | sudo docker import - test/ubuntu:v1.0`


#### 常用组合命令

| 命令 | 说明 |
| ---: | ---: |
| docker rm $(docker ps -a -q) | 清理所有处于终止状态的容器 |
| docker-compose run --rm <compose-name> bash | 临时打开一个用后即删的 container 并连接到 bash |
| docker exec -it <container-name> bash | 连接到一个运行中的 container |



### Dockerfile

#### Dockerfile 构成：

| 功能说明 | 关键字 |
| ---: | ---: |
| 基础镜像信息 | FROM |
| 维护者信息 | MAINTAINER |
| 镜像操作指令 | RUN ADD EXPOSE |
| 容器启动时执行指令 | CMD |

Dockerfile 中每一条指令都创建了Docker镜像中的一层

#### Dockerfile 关键字详细说明

| 关键字 | 说明 |
| ---: | ---: |
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


## 原理

### docker 在操作系统中的隔离
+ Namespaces 隔离的第一级，确保每一个容器中运行一个进程，而不影响容器以外的其他进程
+ Control Groups 是 LXC 的重要组成部分，具有资源核算与限制的关键功能
+ UnionFS 容器的构建块，支持 Docker 的轻量级以及快速性，构建了用户层
