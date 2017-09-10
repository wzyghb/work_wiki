# 常见的 linux 命令总结

[linux tools](http://linuxtools-rst.readthedocs.io/zh_CN/latest/index.html)

## table cheat

| 命令 | 说明 | 补充 |
| :--- | :--- | :--- |
| wc | 统计文件行数 | -c -l -w |
| grep |  |  |
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

## 查看系统的版本

+ `cat /proc/version`
+ `uname -a`
+ `lsb_release -a`
+ `cat /etc/issue`

## shell 的设置

通常使用 `set` 命令来设置shell。 [set](http://www.cnblogs.com/liduanjun/p/3536996.html)

+ `-e` 如果一个命令返回非 0 退状态值，就失败

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

```bash
nohup ./output/start.sh ./output/ > gateway_test.log 2>&1 & echo $! > gateway_test.pid
```

## `runit` 套件

[参考](http://smarden.org/runit/)

`runit` 是一个用于服务监控的 UNIX 控件，提供了以下两种功能：

+ 当服务启动时，启动定义好的服务
+ 监控运行的服务，当服务意外发生中断的时候，自动重启服务

### 安装

+ `apt-get install runit`
+ `ps -ef | grep runsvdir`

> `root         1     0  0 03:14 ?        00:00:00 /usr/bin/runsvdir -P /etc/service` 表示已经安装

### runsvdir

+ 当 runsvdir 检查到 `/etc/service` 目录下包含一个新的目录时，`runsvdir` 会启动一个 `runsv` 进程来执行和监控 run 脚本。
+ 当 `runsvdir` 在 `/etc/service/` 目录中发现新的配置时，它会继续查找子目录 log，如果找到了则启动 `runsv` 进程来执行和监控 log 目录下的 run 脚本。

### 管理服务

+ 检查状态： `sv status example`
+ 停止服务： `sv stop example`
+ 重启服务： `sv restart example`

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
