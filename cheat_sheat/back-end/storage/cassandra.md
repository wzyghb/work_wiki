# Cassandra 基本资料

+ Cassandra 架构

## 资料总结

+ [DataStax Cassandra 文档](http://docs.datastax.com/en/cassandra/3.0/index.html)
+ [Python Driver 官方文档](https://datastax.github.io/python-driver/)
+ [Python Driver Github](https://github.com/datastax/python-driver)
+ [Cassandra 架构](http://zqhxuyuan.github.io/2015/08/25/2015-08-25-Cassandra-Architecture/)
+ [Cassandra Architecture](https://dzone.com/articles/introduction-apache-cassandras)

## 补充分布式系统的资料

+ [gossip 算法]()
+ [raft 算法]()
+ [bloom filter]()
+ [Merkle Tree]()
+ [Murmur3Partitioner MurmurHash](http://docs.datastax.com/en/cassandra/3.0/cassandra/architecture/archPartitionerM3P.html)
+ [LogStructuredMergeTree](https://en.wikipedia.org/wiki/Log-structured_merge-tree)


## 基本概念

### 各种key

[key 的定义解释](http://datascale.io/cassandra-partitioning-and-clustering-keys-explained/)

### Materialized View

Materialized View 由另外一个表的数据构建得到，但是有不同的 key 和新的 properties。在 Casssadra 中，查询使用 primary key 来定义。一般的实践方法是，创建一个表用于查询，然后创建另一个表用于不同的其他查询。在 cassandra 3.0 之前， 这些额外的表都需要在客户端应用中手动增加。而 Materialized View 可以更具他的原数据表来自动的更新数据。

Secondary indexes 适用于不太常用的数据的查询。如果这个列有很高的查询需求，并需要 Cassandra 在一个查询中访问集群中所有的结点，这回引起较高的阅读延迟。Materialized View 适用于较高频率的查询数据。在 Materialized view 中的数据会按照 view 的 Primary Key 重新组织。

+ 原始表中的 primary key 必须在 Materialized view 中也是 primary key。
+ 只能有一个新的列可以增加到 Materialized view 的 primary key 中。而且不能使 static columns。

CREATE MATERIALIZED VIEW 语句有如下特征:

+ AS SELECT 语句将列中的数据复制到 Materialized view 中，
+ FROM 子句标识了 Cassandra 中用于复制数据的 source table。
+ WHERE 子句包括所有的 primary key 列包括 IS NOT NULL 阶段，限定哪些行拷贝到 Materialized view 中。
+ 由于原始表使用 cid 作为其 primary key，因而在 Materialized view 中，也应该使用 cid 作为其 primary key。
+ 注意在 Materialized view 中 age 变成了 patition key，而 cid 变成了 clustering column。

在 cassandra 3.10 及其之后的版本中，materialized view 能够使用 filtering 语句创建，包括在 non-primary-key 列上增加限制。

完成了 materialized view 的创建后，当更新 source table 的数据后，materialized view 的数据会同步更新。materialiezd view 的查询方式和普通的 cassandra 表没有差异，但是写入性能较差。Cassandra 增加了一个额外的read-before-write 来更新每个 materialized view。为了完成更新，cassandra 在每一个 replica 上进行一次数据一致性检查。这回带来源数据表的写入和删除时延。Cassandra 也可以支持直接写入到源表中，当数据已近插入到 source table 后，再异步地进行同步。

### 集合

在关系数据库中，用户拥有多个 email、电话之类的会导致创建多个关系表，然后查询时会有很多个 join 操作。当集合中的数据是有限定时，推荐使用 collections 来存储数据。如果数据的增长潜力是无限时，比如消息发送、事件发生这种没有边界的数据，不要使用 collections 来存储这种数据。而是使用 compound primary key 在 clustering column 中存储数据。

注意：

+ 不要将超过 2 billion 条目存储到集合中。而且只有 number 可以用于查询。
+ map 集合中最大的 key 的数量是 65535
+ list 集合的最大尺寸不能超过 2 GB
+ set 集合每个元素的大小不能超过 65535 bytes
+ 始终保持集合的数据比较小，由此来避免查询过程中的时延。 cassandra 只能整体地将集合全都 load 出来。
+ lists 会引发一个 read-before-write 的操作，因而最好在可能的地方使用 set

注意：

+ 没有定义 clustering column 的表不能够拥有 static column
+ 一个定义了 COMPACT STORAGE 不能够直接拥有一个 static column
+ 作为 partition key 的列不能成为 static

### 索引使用

改进：SSTable Attached Secondary Indexes (SASI)

注意，在以下情况下不要使用 index：

+ 在一个数据量极大的表中查询一小部分数据。[参考](http://docs.datastax.com/en/cql/3.3/cql/cql_using/useWhenIndex.html#useWhenIndex__highCardCol)
+ 在使用 counter 列的表中。
+ 在一个需要经常插入和删除列的表中。

重要概念： cardinality 基数，一般来说如果数据是文章实体，每个都包含大量的数据，则这个列是高基数的，反之如果只是 bool 类型的，则是低基数的。

### 负载均衡

#### TokenAwarePolicy

一个可以包装其他 Policy 的负载均衡 Policy，使得被包装的 Policy 也可以使用 Token。

+ distance method 继承自 child policy
+ 如果可能，`newQueryPlan` 方法会给 query 返回 Local replicas (基于 `Statement.getRoutingKey` 如果 `getRoutingKey` 没有返回 null 且 getReplicas 没有返回 partition key 副本的 empty set)。只有没有发现本地副本和没有成功连接到时，剩余的查询计划会降级使用 child policy。

注意：只有 child policy 的距离函数返回 `HostDistance.LOCAL` 时才会变成优先。例如，如果包装 `DCAwareRoundRobinPolicy` 时，远程数据中心的数据总是
在本地数据中心的数据返回后才返回。

#### [DCAwareRoundRobinPolicy](http://docs.datastax.com/en/cassandra/3.0/cassandra/architecture/archDataDistributeReplication.html#archDataDistributeReplication__nts)

一个辨识数据中心的 Round-Robin 负载均衡算法。
这个策略设定了每个数据中心中有多少个副本。
副本的策略定义在 keyspace 之上。

更加局部地写入，避免跨中心的传输损耗；同时保证出错时会完整处理。常见配置：

+ 每个数据中心有两个副本：允许一个节点出错，并且在一致性级别设定为 ONE 时保持可用。
+ 每个数据中心有三个副本：一致性级别为 LOCAL_QUORUN 时，允许有一个节点失败，一致性级别为 ONE 时允许两个节点失败。

### [Repair](http://docs.datastax.com/en/cassandra/3.0/cassandra/operations/opsRepairNodesTOC.html#opsRepairNodesTOC)

由于各种原因，Cassandra 可能会出现各种数据不一致的情况，需要定期进行修复。

+ Hinted Handoff
+ Read Repair
+ Anti-Entropy Repair
  + nodetool repair **应该变成日常维护的一个操作**

> [Anti-Entropy Repair 的原理](http://docs.datastax.com/en/cassandra/3.0/cassandra/operations/opsRepairNodesManualRepair.html#opsRepairNodesManualRepair)

### [Snitch]

A snitch determines which datacenters and racks nodes belong to.

+ Dynamic
+ Simple
+ RackInferring
+ GossipingPropertyFile
+ ...

### [Gossip](http://docs.datastax.com/en/cassandra/3.0/cassandra/architecture/archGossipAbout.html)

周期性地和其他节点交换状态信息。每秒运行一次，对象是集群中另外的三台节点。有版本信息，因而xin的信息会覆盖旧的信息。

+ 作用：发现、共享位置和状态数据。
+ 每个集群中必须有一个节点在 seed list 中。
+ seeds 中的机器越少越好 (why?)，每个集群最多三台。

#### Failure detection and recovery

Cassandra use this infomation to avoid routing client requests to unreachable nodes whenever possible.

Rather than have a fixed threshold for marking failing nodes, Cassandra uses an accrual detection mechanism to calculate a per-node threshold that takes into account network performance, workload, and historical conditions. 

### [Partitioner](http://docs.datastax.com/en/cassandra/3.0/cassandra/architecture/archPartitionerAbout.html)

determines which node will receive the first replica of a piece of data, and how to distribute other replicas across other nodes in the cluster.

A partitioner is a hash function that derives a token from the primary key of a row.

[partition index\ partition summary](https://stackoverflow.com/questions/26244456/internals-of-partition-summary-in-cassandra)

#### Virtual Nodes

将数据更加细致地分散到节点上。

+ token 可以自动地计算并且分散到每个节点上。
+ 当有 node 加入时可以快速的 rebalance。
+ Rebuilding a dead node is faster。
+ Computer in a cluster has different capacity。

> [数据在 cassandra 中的分布](http://docs.datastax.com/en/cassandra/3.0/cassandra/architecture/archDataDistributeDistribute.html)

### Storage Engine

A, B client write to cassandra parallel, result a race condition. To avoid using read-before-write for most
writes in Cassandra, the storage engine groups inserts and updates in memory, and at intervals, sequentially
writes the data to disk in append mode.
Once written to disk, the data is immutable and is never overwritten. Reading data involves combining this immutable sequentially-written data to discover the correct query results.

> [cassandra 中的事务](http://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlLtwtTransactions.html)

#### Data write process

+ Logging data in the commit log
+ Writing data to the memtable
+ Flushing data from the memtable
+ Storing data on disk in SSTables

什么时候写到 disk 的 sstable 中：

1. memtable content 超过了设定的 threshold
1. commitlog space 超过了 commitlog_total_space_in_mb

通过将这些数据顺序地发送给一个队列，实现写入到 disk。

队列的配置参数：

+ `memtable_heap_space_in_mb`
+ `memtable_offheap_space_in_mb`
+ `memtable_cleanup_threshold`

也可以通过 `nodetool flush` 和 `nodetool drain` 来 flush 一个 table。 在重启一个节点前最好 flush 下 memtable，减少 commit log 的 replay 次数。

当 memtable 写入到 sstable 后， commit log 中对应的数据会被清理。

memtable 和 sstable 会区分每个 table 单独进行维护。而 commit log 会在各个 tables 间共享数据。
[所有的存储文件介绍](http://docs.datastax.com/en/cassandra/3.0/cassandra/dml/dmlHowDataWritten.html)：

| 文件名 | 说明  |
| :---  | :--- |
| `xxx-Data.db` | SSTable data |
| `xxx-Index.db` | row key to data file positions |
| `xxx-Filter.db` | bloom filter， check if exists in SStable |
| `xxx-CompressionInfo.db` |  |
| `xxx-Statistics.db` |  |
| `Digest |  |
| `xxx- CRC.db` |  |
| `SUMMARY.db` |  |
| `TOC.db` |  |
| `Sl_.*.db` |  |

cassandra 为每个 table 创建了单独的存储目录，因而我们可以将数据分散到不同的物理位置上，如快的数据放在 ssd 上。

#### Compaction

cassandra 将新版本的数据(经过 update) 以不同的 timestamp 写入到不同的的 SSTable 中。最终每个 version 的数据
分散在一个 columns 的集合中，拥有不同的 timestamp。因而为了获取完整的一行数据，可能需要访问越来越多的 SSTable 来获取
数据。

Merge SSTable is performant, because rows are sorted by partition key within each SSTable.

1. start compaction
1. merge data
1. evict tombstones remove deletions
1. end compaction

##### Compaction Strategies

+ SizeTieredCompactionStrategy (STCS)
+ LeveledCompactionStrategy (LCS)
+ TimeWindowCompactionStrategy (TWCS)
+ DataTieredCompactionStrategy (DTCS)

#### Update



## Problems

### 0 time in cassandra

[why cassandra time important](http://zhaoyanblog.com/archives/271.html)

### 1 Prepared statement 是不是绑定在一个 session 上。或者只能在一个 session 上用？

一个 Prepared Statement 衍生自一个特定的 session 实例。session 实例又和唯一的 cluster 实例相关，允许其被查询。Prepared Statement 因而不能够单独存在，因而不能在在 session间移动它。通常每个 application 会拥有一个 keyspace。

### 2 如何获得 Cassandra Driver 的 token range 呢？

在 cassandra 的 system keyspace 中存储了 cassandra 相关的配置信息。cassandra 使用了 gossip 协议来同步不同节点之间的信息。

### 3 如何实现批量的写入？

使用 batches 的接口是最佳的一次写入多个表的方式。但是要保持 batches 是比较小的，最多一次写入 5 kb 的数据。batches 保证了原子性，但是并非性能最优。
> cassandra 的 batches 通常会被误认为是性能的优化，虽然 batch 在极少的 case 下确实可以优化性能，我们首先讨论几种类型的 batches：

+ Unlogged Batch: 通常，一个好的 unlogged batch 对数据的 partition key 做了假设。当所有的 partition key 都是相同时，batch 操作非常地高效，如下面的例子所示：

```sql
BEGIN UNLOGGED BATCH;
INSERT INTO weather_readings (date, timestamp, temp) values (20140822,'2014-08-22T11:00:00.00+0000', 98.2); 
INSERT INTO weather_readings (date, timestamp, temp) values (20140822,'2014-08-22T11:00:15.00+0000', 99.2); 
APPLY BATCH;
```

此时的 batch 操作只需要内部写一次即可，这是 unlogged batch 的典型使用场合。

一个反例是：

```sql
BEGIN UNLOGGED BATCH;
INSERT INTO tester.users (userID, firstName, lastName) VALUES (1, ‘Jim’, ‘James’)
INSERT INTO tester.users (userID, firstName, lastName) VALUES (2, ‘Ernie’, ‘Orosco’)
INSERT INTO tester.users (userID, firstName, lastName) VALUES (3, ‘Jose’, ‘Garza’)
INSERT INTO tester.users (userID, firstName, lastName) VALUES (4, ‘Sammy’, ‘Mason’)
INSERT INTO tester.users (userID, firstName, lastName) VALUES (5, ‘Larry’, ‘Bird’)
INSERT INTO tester.users (userID, firstName, lastName) VALUES (6, ‘Jim’, ‘Smith’)
APPLY BATCH;
```

Unlogged batches 需要 coordinator 为这次插入做所有的工作，并且使一个 node 做很多工作。如果 partition key 不再同一个 node 上，coordinator node 需要额外的网络来协同操作。

+ logged batch

一个常见的例子是：

```sql
BEGIN BATCH;
UPDATE users SET name=’Jim’ where id = 1;
UPDATE users_by_ssn set name=’Jim’ where ssn=’888–99–9999';
APPLY BATCH;
```

这会导致 table 进行同步，并损失性能。反例同上 unlogged batch。在一张表中插入并没有严格依赖关系的数据，而这些数据又没有相同的 partition key。基于以下原因，这会导致性能的极大损失。logged batches 会导致 coordinator 做很多额外的工作，coordinator 主要的角色是保证 table 之间的一致性。当一个 batch 发送出 coordinator node 时，另外的 nodes(个人感觉是 coordinator node) 会发送 batch logs。因而如果这个 coordinator 失败了，这个 batch 将会由另外的两个 node 重试。这显然给 coordinator 和整个 cluster 增加了很多额外的工作量。因而，主要使用 logged batch 的场合是你需要同步地在几张表中写入时，而不是为了性能。

[不使用 batch 以最快的方式加载数据](https://medium.com/@foundev/cassandra-batch-loading-without-the-batch-the-nuanced-edition-dd78d61e9885)

### 4 batches 中使用不同 keyspace

```sql
BEGIN BATCH
   INSERT INTO demo.users (lastname, age, city, email, firstname)    VALUES
   ('Smith', 46, 'Sacramento', 'john@example.com', 'John');
   INSERT INTO demo2.users (lastname, age, city, email, firstname
   VALUES
   ('Doe', 36, 'Beverly Hills', 'jane@example.com', 'Jane');
   INSERT INTO demo3.users (lastname, age, city, email, firstname)   VALUES
   ('Byrne', 24, 'San Diego', 'rob@example.com', 'Rob');
APPLY BATCH;
```

同时在 demo.users、demo2.users、demo3.users 中插入数据。

### 5 通过使用 token aware 连接能够提升性能？

是的，使用 token aware 策略，避免了 client 搞清楚集群中每个 node 使用的 token 的范围的网络开销。
当一个 client 连接到一个 node，但是这个 node 并没有占有用于写入的 token（可以是 primary node 或者 replica node），此时这个 node 需要
和其他的 replica node 来协同，病假写入请求发送过去。这显然没有 client 从一开始就连接到对应的节点快。

### 6 如何设定 Consistency level，是在 driver 上还是在 statement 语句上还是在整个 session 上？

1. 在 Cluster 属性上设定一致性层级，从而任意使用 session.execute 的语句都会使用这个一致性层级：

```python
cluster = Cluster.builder().addContactPoint("192.168.0.30")
   .withQueryOptions(new QueryOptions()
   .setConsistencyLevel(ConsistencyLevel.ONE)
   .withRetryPolicy(DeaultRetryPolicy.INSTANCE)
   .withLoadBalancingPolicy(new TokenAwarePolicy(new DCAwareRoundRobinPolicy()))
   .build();
session = cluster.connect("demo");
```

也可以对每个 session.execute 语句设定特定的 consitency level:

```python
session.execute(new SimpleStatement("INSERT INTO users (lastname, age, city,email, firstname) VALUES ('Jones', 45,'Austin','<a href="mailto:bob@example.com">bob@example.com</a>','Bob')")
.setConsistencyLevel(ConsistencyLevel.ALL));
```

### 7 在 Cassandra 中使用 IN 还是多个并行的 query？

使用 IN 查询语句会降低性能，因为通常很多个结点都需要 query，然后这个语句被发送到 coordinator 去执行。比如使用 IN clause 来查询 60 个子句，coordinator 将会阻塞等待 60 个值来返回，最坏的情况下，这 60 个值分布在 60 个结点上，这不但导致了大的延迟，并且增加了 coordinator 的内存压力。
如果你使用 token awareness作为你的 driver 上的 cluster 配置，这时候更加推荐使用 multiple queries，这时候这些 query 会直接发送给拥有 replica 的结点。而且不要在 where 子句中使用 in 语句。 [异步请求 cassandra](http://www.datastax.com/dev/blog/java-driver-async-queries)

另外 Cassandra 的 Thrift 的 api 基本上废弃了，希望新的项目都使用 CQL3。

### 8 在 loop 中使用 prepared statement 性能很差，如果要批量地通过 prepared statement 批量地插入，哪种方式更好？

```java
PreparedStatement p = session.prepare("select log_entry from log_index where id = ?");
BoundStatement b = new BoundStatement(statement);
int[] array = new int[]{1,2,3,4,5,6,7,8,9,10};
for (int i = 0; i < array.length; i++){
   session.execute(b.bind(array[i]));
}
```

### 9 使用异步并发请求高效地使用 Cassandra

异步执行： 返回一个 ResponseFuture 对象。

```python
# --- 1 ---
from cassandra import ReadTimeout

query = "SELECT * FROM users WHERE user_id=%s"
future = session.execute_async(query, [user_id])

# ... do some other work

try:
    rows = future.result()      # 阻塞直到执行成功为止
    user = rows[0]
    print user.name, user.age
except ReadTimeout:
    log.exception("Query timed out:")

# --- 2 ---
# build a list of futures
futures = []
query = "SELECT * FROM users WHERE user_id=%s"
for user_id in ids_to_fetch:
    futures.append(session.execute_async(query, [user_id])

# wait for them to complete and use the results
for future in futures:
    rows = future.result()
    print rows[0].name

# --- 3 ---
def handle_success(rows):
    user = rows[0]
    try:
        process_user(user.name, user.age, user.id)
    except Exception:
        log.error("Failed to process user %s", user.id)
        # don't re-raise errors in the callback

def handle_error(exception):
    log.error("Failed to fetch user info: %s", exception)


future = session.execute_async(query)
future.add_callbacks(handle_success, handle_error)      # 在 Future 上注册回调函数
```

+ 在 callback 函数中抛出的异常会先 logged，然后会被忽略。
+ 你的 callback 将会在 event loop 线程中执行，如果这个函数执行时间过长，将会阻碍其他的请求响应。


## CQL语句

1. 创建、使用、修改 keyspace
1. 创建 Table
1. 集合操作
1. 自定义类型和函数
1. 插入数据
1. 使用轻量级的锁 CAS
1. 过期时间
1. batch 操作