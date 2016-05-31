
docker-machine
docker
docker-compose

### 安装

```
brew install docker
brew install docker-machine
brew install docker-compose
```

### 试用

+ 创建一个docker machine

```
docker-machine create --driver virtualbox default
```
~/.docker/machine/machines/default


+ 列出所有可用的docker-machine

```
docker-machine ls
```

+ 获得用于配置的命令

```
docker-machine env default

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.101:2376"
export DOCKER_CERT_PATH="/Users/mary/.docker/machine/machines/default"
export DOCKER_MACHINE_NAME="default"
```

+ 将shell连接到docker

```
eval "$(docker-machine env default)"
```

### 启动、停止对应的docker

docker ps   // 在启动后会输出相关的机器信息。
docker-compose stop
docker-compose up -d