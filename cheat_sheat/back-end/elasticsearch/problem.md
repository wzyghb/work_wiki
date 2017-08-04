
## 1. 与 lucene 的区别
    http 接口，json api，分布式集群，分片和副本，负载再平衡，路由。

## 2. es 的准实时 NRT 和真实的实时有什么却别。
    1s 的时延。

## 3. 集群 Cluster、 节点 Node
    节点通过集群名称判断来加入集群。
    es 中的每个节点都有一个唯一的名称进行标识

## 4. 分片和副本 (Shards & Repicas)
    单个节点的容量、速度都有限。将索引切分为分片，分片的数量在创建索引时指定，每个分片都能够独立工作，并且存在于集群中的任意一个节点上。
    es 同时为每个索引的分片创建一个或者多个副本分片，以实现错误恢复，并加速查询。每个 es 默认都具有 5 个主分片和 1 个副本，每个索引
    因而有 10 个分片。

## 5. 查询的关键术语

+ 相关度 relevance
+ 分词器 analysis

## 6. 查询方法

+ 基于术语 Term-based queries: 主要用于反向索引术语的精确匹配
+ 基于全文的查询 Full-text queries

## 7. 精度控制 Controlling Precision

+ 索引只包含所有术语的文档

```json
POST /my_index/my_type/_search
{
    "query":{
        "match": {
            "title": {
                "query":"BROWN DOG!",
                "operator": "and"
            }
        }
    }
}
```

+ 最小匹配 `minimum_should_match`

```json
POST /my_index/my_type/_search
{
    "query": {
        "match": {
        "title": {
            "query": "quick brown dog",
            "minimum_should_match":"75%"
        }
        }
    }
}
```

[minimum_should_matchn 详细使用文档](http://t.cn/RXQcWOm)
    
## 8. ElasticSearch 执行 match 查询的操作步骤：

 1. 检索字段类型 (Check the field type) 如果是全文字段，对查询字符串本身进行分析。
 1. 分析查询字符串 (Analyze the query string)。
 1. 查找匹配文档，即使用 term 在反向索引中进行过滤。
 1. 为每个文档计算分数 (term frequency)

## 9. 一个复杂的查询

```json
POST /_search
{
   "query": {
      "bool": {
         "must": {
            "match": {
               "content": { #1
                  "query": "full text search",
                  "operator": "and"
               }
            }
         },
         "should": [
            {
               "match": {
                  "content": "elasticsearch",
                  "boost": 3 # 2
               }
            },
            {
               "match": {
                  "content": "lucene",
                  "boost": 2 # 3 使用 boost 指定权重，使得包括 elasticsearch 关键字的文章提升到最前面。
               }
            }
         ]
      }
   }
}
```


## 10 常用监控 api 总结

### 1. 监控集群正常运行

```
http://<ip>:<port: default=9200>/_cat/nodes?v&pretty
```

### 2. 获得指定 index 中 指定 doc 的一篇文章

```
http://<ip>:<port: default=9200>/users/user_doc/6388785761453342978
```

### 3. 查询 mappings

```
http://<ip>:<port: default=9200>/users/user_doc/_mapping/
```

### 4. 集群节点状态

```
http://<ip>:<port: default=9200>/_nodes/
http://<ip>:<port: default=9200>/_cluster/health
```

## 11 常用运维 api 总结
### 1. 下线几个节点


### 2. 


## 12 `_routing` 
Document 通过 `routing` 字段写入到一个特定的 index 上。
`routing` 默认是 `_id` 或者 `_parent` ID。 当指定 `routing` 进行查询时，可以降低查询的性能消耗，此时仅会在指定的 `routing` 上进行查询。


```
shard_num = hash(_routing) % num_primary_shards
```
> num_shards 在索引创建时指定。

## 13 Elasticsearch 中 Shard 数目的设定


## 14 Advance Search

+ Word Proximity
+ Partial Matching
+ Fuzzy Matching
+ Language Awareness
