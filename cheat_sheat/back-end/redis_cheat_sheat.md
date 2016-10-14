
## 1. redis 的组成

+ redis-server 是 redis 服务器
+ redis-sentinel redis 的守卫，可执行，用于监控和失败探测
+ redis-cli 一个和 redis 通信的命令行接口
+ redis-benchmark 用于检查 redis 的性能
+ redis-check-aof 和 redis-check-dump: 发射崩溃时的数据存储恢复

## 2. 工作流

### 1. 启动

> redis-server
直接使用这个命令的 redis 仅采用系统的默认配置，在生产环境下，可以使用配置文件。
> redis-server /etc/redis.conf

可以使用 redis 源代码下的 redis.conf 进行修改，生成自己的配置。

### 2. 检查 redis 是否在工作

```
$ redis-cli ping
$ redis-cli                                                                
redis 127.0.0.1:6379> ping
PONG
redis 127.0.0.1:6379> set mykey somevalue
OK
redis 127.0.0.1:6379> get mykey
"somevalue"
```
### 3. 安全的 redis

1. 确保 redis 的端口是在防火墙之后的（default: 6379, additionally: 16379, Sentinal: 26379),不能从外部进行访问。
2. 使用 redis 配置文件确保 redis 只会监听来自小的网络接口的信息。
3. 在配置文件中加入 requirepass 选项，以获取更多的安全层，需要使用 AUTH 命令进行授权
4. 使用 spiped 或者其他的 SSL 通道软件对 redis-server 和 redis-cli 之间的传输进行加密。

### 4. 各种语言的客户端

[说明](http://redis.io/clients)

## 3 持久化

redis 会默认地将数据进行持久化，可以调用 SAVE 命令来手动生成一个数据集快照，在关闭时使用：
```
redis-cli shutdown
```

### 1 总述

+ RDB：在一个特定的时间间隔后持久化一个镜像。
+ AOF 在每个操作后进行 logs，在 server 重启时将会进行 replay，重新构建原始的数据集。命令都是以 redis 协议相同的方式进行记录的。
当日志量过大后，redis 会将以前的日志进行重写。
+ 可以设置 redis 使其完全不进行 persistence。这时候数据的生命周期和 server 是相同的。
+ 可以同时使用 AOF 和 RDB 来进行持久化，重启后，redis 会从 AOF 重新构建数据。

### 2 RDB 的优点

+ RDB 是一个压缩后的单个文件，存储所有的 redis 数据。非常适合于备份。
+ RDB 适合于灾难恢复，压缩后的单个备份文件可以上传到 Amazon S3 远程文件系统上。
+ RDB 的使用不会影响线上性能。fork 一个子进程即可完成所有备份操作。
+ 相比于 AOF， RDB 支持 redis 进行快速的重启。

### 3 RDB 的缺点

+ 当发生诸如断电之类的意外情况时，RDB 会丢失一些数据。
+ 因为 RDB 会 fork 一个子进程进行持久化，当数据集较大以及CPU性能不好时，这是比较昂贵的，可能会导致 redis 停止服务几毫秒到几秒。 AOF 也会 fork 但是会好很多。

### 4 AOF 的有点

+ 使用 AOF redis 是持久的，可以使用不同的 fsync 策略： 完全不进行 fsync，每秒进行 fsync，每个查询都进行 fsync。
+ AOF log 是一个 append only 的文件，所以即使发生崩溃，只有一个不完整的 log 行被写入，也可以使用 redis-check-aof 修复。
+ 可以覆盖掉以节省存储空间。
+ AOF log 容易理解。

### 5 AOF 的缺点

+ AOF 的备份文件会比 RDB 的大
+ AOF 在一些fsync 策略的选择情况下回比 RDB 大。
+ 有一些还没有解决的 bug

### 6 使用建议

+ 若需要提供和 PostgreSQL 类似的稳定性，需要同时提供 两种持久化机制。
+ 若可以丢失一些数据，可以仅使用 RDB。
+ 不要单独使用 AOF。
+ 以后可能会有新的机制，将 AOF 和 RDB 结合起来。

### 7 快照

redis 默认地将数据快照保存在 disk 上，二进制文件名称为：dump.rdb. 也可以通过 SAVE 和 BGSAVE 命令。
配置文件配置如下：
> save 60 1000
这个命令配置 redis 会每 60 秒至少 1000 个 key 修改后进行快照存储。
过程如下：

1. fork 是获得子进程。
2. 子进程您估计护具谢若一个临时的 RDB 文件中。
3. 完成新的 rdb 文件的写入后，会自动删除老文件。
这种方法使得 redis 可以享受到 copy-on-write 的语义。


### 8 AOF

配置文件：
> appendonly yes

命令 BGREWRITEAOF 命令可以压缩 log 文件，使得 redis 可以快速恢复。
AOF 使用 fsync 系统调用将 in-core 状态的文件和存储设备进行同步。
建议每秒实行 fsync。

### 9  AOF 和 RDB 持久化的交互

应该避免 BGSAVE 和 AOF rewrite 的同时出现。
RDB 永远不会在创建后改变。
建议：

+ 创建一个克隆的任务，在一个目录下保存每个小时的 RDB snapshots，而在另一个目录下保存每天的快照。
+ 每次 cron script 运行时，应该使用 find 命令确保老旧的 RDB 文件被删除了。
+ 保证至少每天会将一个 RDB 快照传输到自己数据中心的外部。

## 4 事件通知

PUBLISH __keyspace@0__:mykey del
PUBLISH __keyevent@0__:del mykey

目前的事件分发是不可靠的。
通知的设置参见文档。

## 5 事务

redis 事务的基础：MULTI、EXEC、DISCARD、WATCH
事务可以一次执行多个命令，并且带有以下的保证：
+ 单独的隔离操作，所有的命令都会序列化、按顺序执行，执行过程中不会被其他客户端送来的命令所打断。
+ 原子操作，或者全部执行，或者全部不执行。exec 命令负责触发并执行事务中所有的命令。
    + 如果客户端使用 MULTI 开启一个事务之后，因为各种原因没有执行 EXEC，那么事务中所有的命令都不会被执行。
    + 如果客户端成功在开启事务之后执行 EXEC，那么所有的命令都会被执行

AOF 时如果进程被管理员杀死、断电等不可抗力，那么只会有部分事务被执行。这种情况下，redis 会在重启时汇报一个错误并退出。
redis-check-aof 程序可以修复这个问题，移除 AOF 文件中不完整的事务信息，确保服务器可以顺利启动。

2.2 版本以后的redis 可以使用 乐观锁(optimistic lock) 和 CAS 操作。

### 1 使用

MULTI

DISCARD

EXEC

### 2 事务中的错误

+ 在执行 EXEC 之前，入队的命令可能会出错，甚至出现内存不足之类的问题。
+ 在 EXEC 调用之后出现错误。

注意：事务中有某条/某些命令执行失败了， 事务队列中的其他命令仍然会继续执行 —— Redis 不会停止执行事务中的命令。
redis 也不支持回滚操作，优点是：
+ redis 命令仅会因语法的错误而失败，这种错误不应该出现在生产环境下。
+ 保持 redis 的快速简单。

### 3 redis 的脚本也可以实现类似的事务功能
