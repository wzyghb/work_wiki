
项目的需要，要修改 nginx 的配置，这个具有一定的风险性，所以可以在本机搭建一个 docker 环境对配置内容进行测试。

## 1 获取 docker 镜像

使用 [docker 官方 nginx 镜像](https://hub.docker.com/_/nginx/)
```
docker pull nginx
```

## 2 配置 docker-compose 文件方便启动

```
xxxx-dev-nginx:
    image: nginx
    command: bash -c 'nginx'
    container_name: xxxxx-dev-nginx
    ports:
        - "443:443"
    volumes:
        - /etc/localtime:/etc/localtime:ro
        - ./nginx:/etc/nginx
        - ./log/nginx.err:/var/log/nginx.err
```

启动容器后运行 nginx 命令，将 nginx 的本地配置文件夹 `nginx/` 载入到 `/etc/nginx/` 下作为默认配置。
同时将日志文件也进行映射，这样在本地就可以直接看到日志记录文件了。

## 3 配置 nginx 相关配置文件

nginx 目录如下所示：

```
> nginx
    > sites-enabled
        > xxxx.xxxserver.conf
        > upstream.conf
    > mime.types
    > nginx.conf
    > nginx.crf
    > nginx.key
    > nginx.pid
```

nginx.conf 文件内容如下：

```
worker_processes 1;
error_log /var/log/nginx.err;
pid     nginx.pid;
daemon off;

events {
    worker_connections 1024;
}

http {
    access_log /dev/null;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile        on;
    keepalive_timeout   15;
    gzip    on;
    access_log off;
    gzip_disable "msie6";
    gzip_http_version 1.1;
    proxy_http_version 1.1;
    include sites-enabled/*;
}
```

注意：
+ 日志文件的配置要和 docker 载入的数据卷对应起来
+ 注意目录

upstream.conf 文件如下所示：

```
upstream xx_xxxx_xx {
    server 10.32.11.xx:xxxx weight=5;
    server host:port weight=xx
}
```

xxxx.xxxserver.conf 可以配置如下：

```
server {

    listen 443 ssl;
    server_name www.baidu.net;

    ssl_certificate nginx.crt;
    ssl_certificate_key nginx.key;

    location /nendo_probe/ {
        if ($http_host = "info.baidu.net") {
            rewrite ^.*$  https://eh.baidu.net$request_uri permanent;
        }

        proxy_next_upstream error http_500 http_502;
        proxy_connect_timeout 6s;
        proxy_send_timeout    6s;
        proxy_read_timeout    65s;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Real-Port $remote_port;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Rewrite-URL $request_uri;
        proxy_set_header X-Forwarded-Protocol $scheme;
        proxy_http_version  1.1;

        proxy_pass http://xx_xxxx_xx;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 4 修改系统 hosts 文件

修改系统的 hosts 文件，将域名映射到本地，完成测试, 在 docker 中，其对应的 ip 地址通常是 `192.168.99.100`。

这样就可以进行本地测试了。