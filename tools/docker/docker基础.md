
### 基本命令


#### 镜像

docker pull 

docker images

docker commit

Dockerfile 中每一条指令都创建了Docker镜像中的一层
+ # 为注释
+ FROM 表示Docker以哪个镜像为基础来创建。
+ RUN 会在docker创建时运行。
+ ADD 添加本地文件。
+ EXPOSE 向外部开放端口。
+ CMD命令为容器启动后运行的命令。

编写Dockerfile完成后可以使用：

docker build

来创建镜像。上面的步骤中每一次RUN都会创建一个Container，然后下一次创建前会删除中间的Container。完成镜像的创建过程后，就可以在在docker中启动这个容器。

docker tag 

docker save 导出到本地文件
docekr load 从本地文件加载到本地镜像库

docker rmi 移除本地镜像 移除镜像前要用docker rm删除所有依赖的本地容器
docker rm 移除本地容器

#### 容器

docker run xxx
docker run -d xxx
docker ps xxx
docker logs --tail=1000 xxx

docker start xxx
docker stop xxx
docker attach
