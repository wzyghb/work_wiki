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

## 查看系统的版本

+ `cat /proc/version`
+ `uname -a`
+ `lsb_release -a`
+ `cat /etc/issue`

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

## 远程挂载

+ 设置 ssh 密钥和公钥，实现自动登陆
+ 命令为 `sshfs -o sshfs_sync <user_name>@<dev_server_ip>:<dev_server_path> <local_path>`
