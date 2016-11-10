
## squid 配置

### squid.conf 语法

每行以配置指令开始，后面跟着数字值或关键字。在读取配置文件时，squid忽略空行和注释掉的行（以#开始）

```conf
 cache_log /squid/var/cache.log
        
# define the localhost ACL
    
acl Localhost src 127.0.0.1/32
    
connect_timeout 2 minutes
    
log_fqdn on
```

某些指令取唯一值。在这些情形下，重复赋予该指令不同的值，将覆盖前面的值。
某些指令取列表值。在这些情形下，每一个新增的值都有效。
基于列表的指令，你通常能在同一行中赋予多个值。
许多指令有通用类型。例如，连接超时值是一个时间规范，在数字后面跟着时间单元。 `connect_timeout 3 hours`
大量的指令指向文件大小或者内存额度。 `minimum_object_size 12 bytes`
另一种值得提起的类型是触发器，它的值是on或者off。 `server_persistent_connections on`
配置文件指令能以任何顺序出现。然而，如果某个指令指向的值被其他指令所定义，那么顺序就很重要。
squid.conf文件里的许多东西是大小写敏感的，例如指令名。

### 用户和组的配置
控制权限：`cache_effective_user squid`

### 端口号

http_port指令告诉squid在哪个端口侦听HTTP请求。默认端口是3128。
可见设置多个侦听端口号。
```
http_port 3128
http_port 8080
http_port 192.168.1.1:3128
```

### 日志文件
默认的日志目录是squid安装位置下的logs目录。如 `/usr/local/squid/var/logs`
必须确认日志文件所存放的磁盘位置空间足够。在squid写日志时如果接受到错误，它会退出和重启。
该行为的主要理由应引起你的注意。squid想确认你不会丢失任何重要的日志信息，特别是你的系统被滥用或者被攻击时。

squid 有三个主要的日志文件：

+ cache.log : 包含状态性的和调试性的消息。刚开始运行squid时，你应密切的关注该文件。假如squid拒绝运行，
    理由也许会出现在cache.log文件的结尾处。在正常条件下，该文件不会变得很大。配置：`cache_log /squid/logs/cache.log`
+ access.log文件包含了对squid发起的每个客户请求的单一行。每行平均约150个字节。
    也就是说，在接受一百万条客户请求后，它的体积约是150M。 配置： `cache_access_log /squid/logs/access.log` 
    假如因为某些理由，你不想squid记录客户端请求日志，你能指定日志文件的路径为/dev/null.
+ store.log 包含了进入和离开缓存的每个目标的记录。平均记录大小典型的是175-200字节。 配置： `cache_store_log /squid/logs/store.log`
    禁止： `cache_store_log none`

避免文件过大：日志轮循

### 访问控制
squid默认的配置文件拒绝每一个客户请求。在任何人能使用代理之前，你必须在squid.conf文件里加入附加的访问控制规则。
最简单的方法就是定义一个针对客户IP地址的ACL和一个访问规则，告诉squid允许来自这些地址的HTTP请求。
squid有许多不同的ACL类型。src类型匹配客户IP地址，squid会针对客户HTTP请求检查http_access规则。

### 管理联系信息

```
cache_mgr squid@web-cache.net
```

## squid 运行

+ -a port
+ -d level # 日志记录级别
+ -f file  # 指定配置文件
+ -h # 帮助信息
+ -k function 
    + reconfigure导致运行中的squid重新读取配置文件。
    + rotate导致squid滚动它的日志，这包括了关闭日志，重命名，和再次打开它们。
    + shutdown发送关闭squid进程的信号。
    + interrupt立刻关闭squid，不必等待活动会话完成。
    + kill发送KILL信号给squid，这是关闭squid的最后保证。
    + debug将squid设置成完全的调试模式，假如你的cache很忙，它能迅速的用完你的磁盘空间。
    + check简单的检查运行中的squid进程，返回的值显示squid是否在运行。
    + parse简单的解析squid.conf文件，如果配置文件包含错误，进程返回非零值。
+ -z # 初始化cache，或者交换，目录。在首次运行squid，或者增加新的cache目录时，你必须使用该选项。