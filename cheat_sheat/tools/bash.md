# 常见的 linux 命令总结

+ [linux tools](http://linuxtools-rst.readthedocs.io/zh_CN/latest/index.html)
+ [Advance Bash-Scripting Guide](http://tldp.org/LDP/abs/html/)

## MAC bash 配置

由于使用 zsh，所以要将启动的环境变量配置配置到 `~/.zshrc` 中，或者在 `.zshrc` 中加入语句`source ~/.bash_profile`

## table cheat

| 命令 | 说明 | 补充 |
| :--- | :--- | :--- |
| wc | 统计文件行数 | -c -l -w |
| grep | `-v` `-E` |  |
| find |  |  |
| zgrep |  |  |
| xargs |  |  |
| free |  |  |
| df |  |  |
| du |  |  |
| ipset |  |  |
| iptables |  |  |
| lsof | `-i:<port>` | 查看占用该端口的进程 pid |
| locale | `-a` | 查看容器的所有语言环境 |
| dpkg-reconfigure locales |  | 图像化本地语言环境配置 |
| sort | 排序 |  |
| uniq | 排除相邻行的重复, 和 sort 结合使用 |  |
| date | 时间显示 |  |
| telnet | 端口测试 |  |
| ifconfig |  |  |
| awk |  |  |
| sed |  |  |
| cut |  |  |
| paste |  |  |
| uniq |  |  |
| shuf |  |  |
| xargs |  |  |

+ `date`
  + `date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"`
  + `date -v1d -v3m -v0y -v-1d`

+ `grep`
  + `-v` 排除
  + `-E` 使用正则表达式
  + `-c` 只显示行数
  + `-i` 忽略大小写
+ [`awk`](https://coolshell.cn/articles/9070.html)
+ [`if` 语句编写](http://zhaochj.blog.51cto.com/368705/1315581)

example:

```sh
zgrep "collect event success" *.log.gz | grep -v "Group" | grep -E "iOS|iPhone" | grep "Lark" > test_ios
```

## 查看系统的版本

+ `cat /proc/version`
+ `uname -a`
+ `lsb_release -a`
+ `cat /etc/issue`

## shell 的设置

通常使用 `set` 命令来设置shell。 

+ [set](http://www.cnblogs.com/liduanjun/p/3536996.html)
+ [set 阮一峰](http://www.ruanyifeng.com/blog/2017/11/bash-set.html)

+ `-e` 如果一个命令返回非 0 退状态值，就失败
+ `-u` 遇到未绑定的变量则报错退出
+ `-x` 在运行结果之前，先输出执行的那一行命令
+ `-o pipefail` 因为 `-e` 命令不适合于管道，管道成功失败等价于最后一个命令的状态。

## 让进程在后台可靠运行

用户注销 (logout) 和网络断开时，终端会收到 HUP （hangup) 信号，从而关闭所有子进程，所以有两种办法：

1. 让进程忽略 hangup 信号 ---> `nohup`
1. 让进程运行在新的会话里从而成为不属于此终端的子进程

+ `nohup`
+ `setsid`
+ `&`
+ `disown`
+ `screen`

[参考](https://www.ibm.com/developerworks/cn/linux/l-cn-nohup/index.html)

## 标准输入输出替换说明

[参考](http://blog.csdn.net/ithomer/article/details/9288353)

+ `2>&1`: 标准错误输出重定向于标准输出
+ `1>/dev/null`: 将标准输出重定向到空设备文件，也就是不输出任何信息到终端，不显示任何信息

## `$<x>` 说明

+ `$$` Shell本身的PID（ProcessID）
+ `$!` Shell最后运行的后台Process的PID
+ `$?` 最后运行的命令的结束代码（返回值）
+ `$-` 使用Set命令设定的Flag一览
+ `$*` 所有参数列表。如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。
+ `$@` 所有参数列表。如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。
+ `$#` 添加到Shell的参数个数
+ `$0` Shell本身的文件名
+ `$1`～`$n` 添加到Shell的各参数值。$1是第1参数、$2是第2参数…。

example: 启动命令，并保存 pid 到指定文件

```sh
nohup ./output/start.sh ./output/ > gateway_test.log 2>&1 & echo $! > gateway_test.pid
```

## `runit` 套件

+ [参考](http://smarden.org/runit/)
+ [runit 快速入门](https://segmentfault.com/a/1190000006644578)

`runit` 是一个用于服务监控的 UNIX 控件，提供了以下两种功能：

+ 当服务启动时，启动定义好的服务
+ 监控运行的服务，当服务意外发生中断的时候，自动重启服务

### 安装

+ `apt-get install runit`
+ `ps -ef | grep runsvdir`

> `root         1     0  0 03:14 ?        00:00:00 /usr/bin/runsvdir -P /etc/service` 表示已经安装

### runsvdir

+ 当 runsvdir 检查到 `/etc/service` 目录下包含一个新的目录时，`runsvdir` 会启动一个 `runsv` 进程来执行和监控 run 脚本。
+ 当 `runsvdir` 在 `/etc/service/` 目录中发现新的配置时，它会继续查找子目录 log，如果找到了则启动 `runsv` 进程来执行和监控 log 目录下的 run 脚本。 会在 `/etc/sercice/service_name/` 下创建一个 `supervise` 文件夹，保存各种状态。

example:

比如说要在同一 docker 中执行 web、service、celery 三种类型的服务，于是同时创建三种启动脚本如下：

> **example: web.sh**

```sh
#!/usr/bin/env bash
set -ex
umask 022
cd ${PROJECT_ROOT}
eval $(python deploy/env.py)
export ENV_VAR=`pwd`xxxx
exec  gunicorn -c gunicorn_config.py app_package:app
```

其他脚本类似，此处忽略。

然后将这个脚本挂载到 `/etc/service/web/run`、`/etc/service/service/run`、`/etc/service/celery/run`。注意是每个目录下都有一个 run 的脚本。

然后在 docker 启动时运行以下脚本来执行上述服务的脚本：

```sh
#!/usr/bin/env bash

# 找到所有该目录下的文件
FILES=`find /etc/service/ -name run`

# 给该目录下的文件增加执行权限
if [ "${FILES}" ]; then
  chmod a+x ${FILES}
fi

# 使用 runsvdir 命令执行脚本。
exec /usr/bin/runsvdir -P /etc/service
```

### 管理服务

+ 检查状态： `sv status ssh`
+ 停止服务： `sv stop service`
+ 重启服务： `sv restart ssh` 和 `service ssh restart` 等价

> 注意服务的名称就是 `/etc/service/` 下的文件夹名称，每个文件夹下都有一个 run 可执行文件。

## SSH

+ SSH 一种网络协议，用于计算机之间的加密登陆。可以安全的登陆另一计算机确保不会被中途截获。
+ SSH 在 linux 中自带，windows 需要使用 PuTTy 客户端。

### 远程挂载

+ 设置 ssh 密钥和公钥，实现自动登陆
+ 命令为 `sshfs -o sshfs_sync <user_name>@<dev_server_ip>:<dev_server_path> <local_path>`

### 指令

+ `ssh user@host`
+ `ssh host`
+ `ssh -p 2222 user@host`

### 原理以及安全性

步骤：

1. 远程主机收到用户登陆请求，并且将自己的公钥发送给用户。
1. 用户使用这个公钥，将登陆密码加密后发送回来。
1. 远程主机使用自己的密钥，解密登陆密码，如果密码正确，就同意用户登陆

> 中间人攻击如何突破 ssh 协议？

第一登陆，会弹出如下对话：

```sh
　$ ssh user@host
　　The authenticity of host 'host (12.18.429.21)' can't be established.
　　RSA key fingerprint is 98:2e:d7:e0:de:9f:ac:67:28:c2:42:2d:37:16:58:4d.
　　Are you sure you want to continue connecting (yes/no)? <1>

  Warning: Permanently added 'host,12.18.429.21' (RSA) to the list of known hosts. <2>

  Password: (enter password) <3>
```

1. 这个表示无法确认 host 主机的真实性，只知道他的 公钥指纹，是否继续连接。一般远程主机需要贴出自己的公钥指纹来让用户自行核对。
1. 表示这个指纹被 host 主机所认可
1. 要求输入密码
1. 远程主机的公钥被接收后，会被保存到 `$HOME/.ssh/known_hosts` 之中，下次再连接这台主机时，系统就会认出他的公钥已经保存在本地了，会跳过警告部分，直接输入密码。

> 公钥指纹： 公钥长度较长，采用 RSA 算法时，长度达到 1024 位，很难对比，对其进行 md5 运算，变成一个 128 位的指纹。

ssh 的公钥登陆

使用密码登陆，每次都需要输入密码，非常麻烦，所以 ssh 提供了 公钥登陆 机制，原理很简单，就是用户将自己的公钥存储到远程主机上，登录时远程主机会向用户发送一段随机的字符串，用户用自己的私钥加密后，再发回来。远程主机事先存储了公钥，其使用公钥进行解密，如果成功，说明用户是可信的，用户用户登陆 shell，否则。

通常使用 `ssh-keygen` 生成用户的哦公私钥。如果担心私钥的安全，可以设置 `passphrase`。使用 `ssh-copy-id user@host` 将公钥传输到远程主机上。

为了保证远程主机可以接受，需要检查 `/etc/ssh/sshd_config` 这个文件，检查下面几行：

```yml
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

取消以上各行的注释，然后使用以下命令重启 ssh 服务：

```sh
// ubuntu系统
service ssh restart
// debian系统
/etc/init.d/ssh restart
```

docker 中通常使用 sshd 命令来启动 ssh 服务， 参见 [sshd doc](http://man.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/sshd.8?query=sshd%26sec=8)

example:

1. 在 docker / 机器上安装相关的软件 `apt-get update && apt-get install -y runit openssh-server`
1. 使用 `ssh-keygen` 生成用户公私钥
1. 将公钥上传到 `docker` 虚拟机的 `/var/run/sshd/authorized_keys` 中。
1. 配置 `/etc/ssh/sshd_config` 文件。
1. 编写 sshd 命令启动脚本。
1. 将这个脚本作为一个服务 (参见上面的 runit 套件使用说明) 挂载到 `/etc/service/sshd/run` 文件。
1. 如果已经配置了，可以使用 `service ssh restart` 使配置生效
1. 本地登陆 `ssh -i ~/path_to_private_key/id_rsa -p 22222 root@127.0.0.1` [ssh doc](https://www.freebsd.org/cgi/man.cgi?sshd(8))

注意事项：

+ 本地的私钥必须要将权限设置为 400 或者 600，不能多也不能少，否则会报错误
    ```text
    Permissions 0777 for '/Users/username/.ssh/id_rsa' are too open.
    It is recommended that your private key files are NOT accessible by others.
    ```
+ 注意下面的配置中将 ssh 的端口设定为 22，所以在 docker 中要将该端口导出，上面的命令中导出为 22222
+ 配置过程中还出现了 `ssh_exchange_identification` 的错误，可以参照这个 [error explain](http://edoceo.com/notabene/ssh-exchange-identification)

可参见 [`sshd_config` 文档](https://www.freebsd.org/cgi/man.cgi?sshd_config(5)) 实现如下的配置：

```yml
Port 22
ChallengeResponseAuthentication no
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
Protocol 2
PermitRootLogin yes
PasswordAuthentication no
MaxStartups 100:30:200
AllowUsers root
PrintMotd no
PrintLastLog no
PubkeyAuthentication yes
AuthorizedKeysFile /var/run/sshd/authorized_keys
UsePAM no
Subsystem sftp /usr/lib/openssh/sftp-server

# Disabling use DNS in ssh since it tends to slow connecting
UseDNS no
```

sshd service 的启动脚本可以是：

```sh
#!/usr/bin/env bash

set -e
umask 022

if [ -f /var/run/sshd/id_rsa.pub ]; then
 cp /var/run/sshd/id_rsa.pub /var/run/sshd/authorized_keys
 chmod 400 /var/run/sshd/authorized_keys
fi

exec /usr/sbin/sshd -D -f /etc/ssh/sshd_config -e
```

## make

[ref](http://www.ruanyifeng.com/blog/2015/02/make.html)
