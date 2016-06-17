
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

+ docker-machine start default          // 启动docker机器
+ docker ps                             // 在启动后会输出相关的机器信息。
+ docker-compose stop
+ docker-compose up -d                  // 打开


### bugfix

出现下面的问题：

```
>>> docker-machine env default (运行这一命令)
Error checking TLS connection: Error checking and/or regenerating the certs: 
There was an error validating certificates for host "192.168.99.100:2376": 
tls: DialWithDialer timed out
```

解决方案如下：
+ 首先停止运行的docker机器
    docker-machine stop default
+ 删除这个docker机器
    docker-machine rm default
+ 创建一个新的docker机器
    docker-machine create --driver virtualbox default
+ 将docker机器绑定到当前的shell
    eval $(docker-machine env default)
+ 在docker配置文件夹下运行一下命令，重新安装container
    docker-compose up -d
+ 导入测试数据
    docker-compose run --rm malaita-web bash -c 
    'source ../python3/bin/activate && eval `python deploy/env.py` 
    && python manage.py db upgrade heads && python malaita/tests/test_data.py'
+ 启动web-package
    docker-compose run --rm malaita-web bash -c 
    'cd front-end; npm install; ./node_modules/.bin/webpack -w'

+ 端口

malaita-web: 5000 malaita-mysql: 3306

### 使用命令说明

#### 1
docker-compose run -rm malaita-web bash
进入到docker的bash中去，开始运行bash

#### 2
启动和停止某个特定的容器：
+ docker-compose stop malaita-web
+ docker-compose start malaita-web

#### 3
另一种运行docker容器bash的方法：
docker exec -it malaita-web bash

#### 4
查看logs：
docker logs --tail=100 malaita-web
docker-compose logs malaita-web

#### 5 
本地开发测试：
docker-compose -f docker-compose.test.yml up -d

git fetch ssh://lifei@review.byted.org:29418/ee/malaita refs/changes/98/115098/15 && git checkout FETCH_HEAD
