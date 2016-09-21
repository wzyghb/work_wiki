
## 初步设置
```
java -version
echo $JAVA_HOME
curl -L -O    https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.3/elasticsearch-2.3.3.tar.gz

tar -xvf elasticsearch-2.3.3.tar.gz
cd elasticsearch-2.3.3/bin
./elasticsearch
./elasticsearch --cluster.name my_cluster_name --node.name my_node_name
```

## 集群

+ 检查您的群集，节点和索引的健康，状态和统计信息
+ 管理你的集群，节点和索引数据和元数据
+ 执行CRUD（创建，读取，更新和删除），并针对您的索引搜索进行操作
+ 执行高级搜索操作，如分页，排序，筛选，脚本，聚合，还有许多其他的事情

### 集群信息统计输出

一般使用 _cat API 来进行集群健康检查。

```
curl 'addr:port/_cat/health?v'
>>>

epoch      timestamp cluster status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1474374762 20:32:42  malaita green           3         3      7   3    0    0        0             0                  -                100.0%

> 获得节点的信息
curl 'localhost:9200/_cat/nodes?v'
> 列出所有的索引
curl 'localhost:9200/_cat/indices?v'
```

### 创建和查询索引

```
> 创建一个名称是 customer 的索引，并且使用 pretty 来美化返回结果。
curl -XPUT 'localhost:9200/customer?pretty'
```

#### 索引文档
```
curl -XPUT 'localhost:9200/customer/external/1?pretty' -d '
{
  "name": "John Doe"
}'

> 返回结果
{
  "_index" : "customer",
  "_type" : "external",
  "_id" : "1",
  "_version" : 1,
  "created" : true
}
```

#### 查询文档
```
curl -XGET 'localhost:9200/customer/external/1?pretty'

{
  "_index" : "customer",
  "_type" : "external",
  "_id" : "1",
  "_version" : 1,
  "found" : true,
  "_source" : { "name": "John Doe" }
}
```

### 删除文档

```
curl -XDELETE 'localhost:9200/customer?pretty'
{
  "acknowledged" : true
}
curl 'localhost:9200/_cat/indices?v'
health index pri rep docs.count docs.deleted store.size pri.store.size

curl -X<REST Verb> <Node>:<Port>/<Index>/<Type>/<ID>
```