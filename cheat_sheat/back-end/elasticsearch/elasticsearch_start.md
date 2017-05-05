
业务研发中通常会有搜索需求，Elasticsearch 是常用的搜索引擎工具，这个 cheatsheat 主要组成如下：
+ 搜索的相关概念
+ Elasticsearch 基础 api
+ Elasticsearch-py 和 Elasticsearch-dsl 基本使用

参考资料：
+ [Elasticsearch 权威指南](https://es.xiaoleilu.com/)。
+ [elastic 官网](https://www.elastic.co/)
+ [elasticsearch reference](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
+ [elasticsearch-py](https://elasticsearch-py.readthedocs.io/en/master/)
+ [elasticsearch-dsl](https://elasticsearch-dsl.readthedocs.io/en/latest/)
+ [elasticsearch-analysis-ik](https://github.com/medcl/elasticsearch-analysis-ik)
+ [elasticsearch-analysis-pinyin](https://github.com/medcl/elasticsearch-analysis-pinyin)
+ [Cerebro](https://github.com/lmenezes/cerebro) es 的管理系统
+ [head](https://github.com/mobz/elasticsearch-head) es 集群的前端界面，暂时不支持 es 5.x
+ [bigdesk](https://github.com/lukas-vlcek/bigdesk) es 的统计和监控平台
+ [ES 配置的例子](https://github.com/hangxin1940/elasticsearch-cn-out-of-box)

## 搜索的相关概念

+ 索引

## Elasticsearch

### 概念

| 名词 | 中文 | 解释 |
| :--- | :--- | :--- |
| cluster | 集群 |  |
| node |  | 结点 |
| indices | 索引 |  |
| types |  | 类型 |
| documents | 文档 |  |
| fields | 域 |  |
| shard | 分片 |  |
| replica | 副本 |  |
| requesting node | 请求节点 | 实际收到查询请求的节点 |
| mapping | 映射 | 用于字段类型确认，如 string、number、booleans、date |
| schema definition | 模式定义 |  |
| analysis | 分析 | 进行全文文本分词，用于后续反向索引的使用 |
| full text | 全文文本 |  |
| exact values | 确切值 | 不可分割的部分 |
| tokenizer | 分词器 |  |
| token filters | 标记过滤 |  |
|

+ 每个索引有一个或者多个分片，N 个不同的分片最好存储在不同的 node 上，以较好地实现负载均衡。
+ 副本有主、副之分，就是复制的分片，以实现容灾、快速查询。
+ 分片算法：`shard = hash(routing) % number_of_primary_shards`。 routing 默认是 `_id` 但也可以自定义。
+ 

| 数据库 | ES |
| :--- | :--- |
| Databse | Indics |
| Tables | Types |
| Rows | Documents |
| Columns | Fields |

### [插件](https://www.elastic.co/guide/en/elasticsearch/plugins/current/intro.html)

ElasticSearch 的插件可以分为两部分：
+ Core Plugins
+ Community contributed

使用命令行：
```bash
./bin/elasticsearch-plugin -h
```
查看插件相关的帮助信息。

### 配置项

+ `cluster.name`
+ `node.name`
+ `network.host`
+ `http.port`
+ `path.logs`
+ `discovery.zen.ping.unicast.hosts: ["10.6.16.24","10.3.132.35","10.3.132.50"]`
+ `node.master`
+ `node.data`
+ `discovery.zen.minimum_master_nodes: 2`
+ `index.number_of_replicas: 2`
+ `index.number_of_shards: 5`


### Starting

+ [Install](https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html)

### API reference 简介

#### 分词结果测试
```
curl -XPOST 'http://10.4.17.18:9200/group_chats/_analyze?pretty' -d '
{
    "analyzer": "pinyin",
    "text": "效率yufuwubu"
}'
```

#### 集群管理

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

## elasticsearch_dsl

elasticsearch 是 python 基础的 elasticsearch 连接库。

### 基础配置

一般推荐使用 `elasticsearch_dsl.serializer.serializer` 这会保证对象每次都会转化为 json。传递给 elasticsearch。`create\_connectiion` 方法会自动地做这些工作如果你不明确地使用其他的 `serializer`。当你要 `serializer` 自己定义的对象时，需要自己实现 `to_dict` 方法。

### 连接到 ES

```python
import elasticsearch.Elasticsearch
from elasticsearch_dsl.connections import connections
# 1 single
s = Search(using=Elasticsearch('localhost'))
s = s.using(Elasticsearch('otherhost:9200'))
# 2 default only
connections.create_connection(hosts=['localhost'], timeout=20)
# 3 multi-cluster
connections.configure(
    default={'hosts': 'localhost'},
    dev={
        'hosts': ['esdev1.example.com:9200'],
        'sniff_on_start': True
    }
)
# 4 add new connection
connections.add_connection('qa', my_client)
```
### Search

+ queries 查询
+ filters 过滤
+ aggregations 聚合
+ sort  排序
+ pagination 分页
+ additional parameters 附加参数
+ associated client 相关客户端

API 是可以进行链式请求的，因而 Search 对象是不可变的。使用如下：

#### 1 基础查询
```python
from elasticsearch import Elasticsearch
from elasticsearch_dsl import Search
client = Elasticsearch()
# 搜索连接对象连接到 ES 实例
client = Elasticsearch()
s = Search(using=client)
s = s.using(client)
# 构建查询语句
s = Search().using(client).query("match", title="python")
# 查看搜索的 restful 语句
print(s.to_dict())
# 进行查询
response = s.execute()
# 遍历结果
for hit in s:
    print(hit.title)
# 从 es 中删除查询结果
response.delete()
```
搜索结果都对被缓存，子序列的查询或者当前搜索对象的反复查询都不会触发 ES 的搜索，而是从缓存中直接获得结果。

#### 2. 使用 MultiMatch 和 Match 子句
```python
from elasticsearch_dsl.query import MultiMatch, Match
# 1. {"multi_match": {"query": "python django", "fields": ["title", "body"]}}
MultiMatch(query='python django', fields=['title', 'body'])
# 2. {"match": {"title": {"query": "web framework", "type": "phrase"}}}
Match(title={"query": "web framework", "type": "phrase"})
# 1 和 2 的简化形式
Q("multi_match", query='python django', fields=['title', 'body'])
Q({"multi_match": {"query": "python django", "fields": ["title", "body"]}})
# 复合查询
# {"bool": {"should": [...]}}
("match", title='python') | Q("match", title='django')
# {"bool": {"must": [...]}}
Q("match", title='python') & Q("match", title='django')
# {"bool": {"must_not": [...]}}
~Q("match", title="python")
# 更加精细的复合语句
Q('bool',
    must=[Q('match', title='python')],
    should=[Q(...), Q(...)],
    minimum_should_match=1
)
# 组合形成完整的查询语句
q = Q("multi_match", query='python django', fields=['title', 'body'])
s = s.query(q)
# 可以复合使用 query 方法，相当于 Q 的 &
s = s.query("multi_match", query='python django', fields=['title', 'body'])
s.query = Q('bool', must=[Q('match', title='python'), Q('match', body='best')])
# 查看构建的查询语句
print(s.to_dict())
```

#### 3. 过滤、排序

```python
# 过滤语句：等价于 s = s.query('bool', filter=[Q('terms', tags=['search', 'python'])])
s = s.filter('terms', tags=['search', 'python'])
# 也可以使用 exclude 语句实现过滤，等价于 
# s = s.query('bool', filter=[~Q('terms', tags=['search', 'python'])])
s = s.exclude('terms', tags=['search', 'python'])
# 排序
s = Search().sort(
    'category',
    '-title',    # 降序
    {"lines" : {"order" : "asc", "mode" : "avg"}}
)
# 重设排序
s = s.sort()
# 翻页 等价于 s.params(size=10, offset_=10)
s = s[10:20]
# 如果想要浏览整个内容，为避免深分页引起的性能问题，应该使用 scan 方法如下
for hit in s.scan():    # 此时不会进行排序
    print(hit.title)
# hightlight
s = s.highlight_options(order='score')  # 设置高亮的属性
s = s.highlight('title')    # 设置 title 字段
# 设置查询请求的额外参数
s = s.extra(explain=True)
# 设置更多 query 参数
s = s.params(from_=10，size=10)
# 限定返回的内容
s = s.source(['title', 'body'])     # 返回 title 和 body 字段
s = s.source(False)                 # 不返回任何字段
s = s.source(include=["title"], exclude=["user.*"]) # 更加细致地进行定义
s = s.source(None)                  # 重设 field
# 序列化和反序列化
s = Search.from_dict({"query": {"match": {"title": "python"}}})
s.to_dict()
```

#### 4. 聚合 A

例子：
```python 
A('terms', field='tags')
# {"terms": {"field": "tags"}}
```

使用 `.bucket()`，`metric` 和 `pipeline` 方法来进行聚合：
```python
a = A('terms', field='category')
# {'terms': {'field': 'category'}}

a.metric('clicks_per_category', 'sum', field='clicks')\
    .bucket('tags_per_category', 'terms', field='tags')
# {
#   'terms': {'field': 'category'},
#   'aggs': {
#     'clicks_per_category': {'sum': {'field': 'clicks'}},
#     'tags_per_category': {'terms': {'field': 'tags'}}
#   }
# }
```

使用 `.aggs` 属性来进行顶层的聚合：

```python
s = Search()
a = A('terms', field='category')
s.aggs.bucket('category_terms', a)
# {
#   'aggs': {
#     'category_terms': {
#       'terms': {
#         'field': 'category'
#       }
#     }
#   }
# }
```

访问已经存在的 bucket 如下：

```python
s = Search()

s.aggs.bucket('per_category', 'terms', field='category')
s.aggs['per_category'].metric('clicks_per_category', 'sum', field='clicks')
s.aggs['per_category'].bucket('tags_per_category', 'terms', field='tags')
```

#### 5 推荐 Suggestions
```python
s = s.suggest('my_suggestion', 'pyhton', term={'field': 'title'})
```

#### 6 Response 也是 ES 返回 json 的数据封装
示例代码：

```python
response = s.execute()
print(response.success())
# True
print(response.took)
# 12
print(response.hits.total)
print(response.suggest.my_suggestions)
response.to_dict()

for h in response:
    print(h.title, h.body)

h = response.hits[0]
print('/%s/%s/%s returned with score %f' % (
    h.meta.index, h.meta.doc_type, h.meta.id, h.meta.score))
# 聚合 aggregations
for tag in response.aggregations.per_tag.buckets:
    print(tag.key, tag.max_lines.value)
```

### 持久化 Persistence

#### 1 Mappings 定义

映射定义了下面简单的模式来查询 DSL:

```python
from elasticsearch_dsl import Mapping, String, Nested
# name your type
m = Mapping('my-type')
# add fields
m.field('title', 'string')
# you can use multi-fields easily
m.field('category', 'string', fields={'raw': String(index='not_analyzed')})
# you can also create a field manually
comment = Nested()
comment.field('author', String())
comment.field('created_at', Date())
# and attach it to the mapping
m.field('comments', comment)
# you can also define mappings for the meta fields
m.meta('_all', enabled=False)
# save the mapping into index 'my-index'
m.save('my-index')
```

#### 2 Analysis
为 String fields 定义特殊的 analyzer：

```python
from elasticsearch_dsl import analyzer, tokenizer

my_analyzer = analyzer('my_analyzer',
    tokenizer=tokenizer('trigram', 'nGram', min_gram=3, max_gram=3),
    filter=['lowercase']
)
```

#### 3 Doctype

```python
from datetime import datetime
from elasticsearch_dsl import DocType, String, Date, Nested, Boolean, \
    analyzer, InnerObjectWrapper, Completion
html_strip = analyzer('html_strip',
    tokenizer="standard",
    filter=["standard", "lowercase", "stop", "snowball"],
    char_filter=["html_strip"]
)
class Comment(InnerObjectWrapper):
    def age(self):
        return datetime.now() - self.created_at
class Post(DocType):
    title = String()
    title_suggest = Completion(payloads=True)
    created_at = Date()
    published = Boolean()
    category = String(
        analyzer=html_strip,
        fields={'raw': String(index='not_analyzed')}
    )
    comments = Nested(
        doc_class=Comment,
        properties={
            'author': String(fields={'raw': String(index='not_analyzed')}),
            'content': String(analyzer='snowball'),
            'created_at': Date()
        }
    )
    class Meta:
        index = 'blog'
    def add_comment(self, author, content):
        self.comments.append(
          {'author': author, 'content': content})
    def save(self, ** kwargs):
        self.created_at = datetime.now()
        return super().save(** kwargs)
```

#### 4 Document Life Cycle
在第一次使用 Post 文档类型之前，应该先在 ElasticSearch 中创建 mapping。或者使用 Index 对象或者使用 init 类方法直接创建映射。

```python
# create the mappings in Elasticsearch
Post.init()
```
为了创建一个 `Post` 文档，只需要初始化类时将需要的域传递即可，如下所示：

```python
# instantiate the document
first = Post(title='My First Blog Post, yay!', published=True)
# assign some field values, can be values or lists of values
first.category = ['everything', 'nothing']
# every document has an id in meta
first.meta.id = 47
# save the document into the cluster
first.save()
```
所有的原数据域（id， parent，routing，index. etc）可以通过 meta 属性访问。

```python
post = Post(meta={'id': 42})
# prints 42, same as post._id
print(post.meta.id)
# override default index, same as post._index
post.meta.index = 'my-blog'
```

获得已经存在的文档可以使用 get 类方法：

```python
# retrieve the document
first = Post.get(id=42)
# now we can call methods, change fields, ...
first.add_comment('me', 'This is nice!')
# and save the changes into the cluster again
first.save()
# you can also update just individual fields which will call the update API
# and also update the document in place
first.update(published=True, published_by='me')
```

如果找不到对应的值，会抛出 `elasticsearch.NotFoundError` 异常。如果设定 ignore=404  则会返回 None，不会抛出异常。

```python
p = Post.get(id='not-in-es', ignore=404)
p is None
```

其他还有 mget 方法使用如下：

```python
posts = Post.mget([42, 47, 256])
```

取决于参数配置，这个方法可能会抛出 没有找到文章`NotFoundError`， 找到的文档有错误`RequestError`。其主要参数有：

+ `raise_on_error`: 如果设定为 True，将会抛出异常，否则当做 missing 来处理。
+ `missing`: 可以有三种可能的值： `None`, `raise` 和 `skip`。

所有关于 Doctype 的信息，包括其 Mapping 都可以通过 _doc_type 类属性来访问。

```python
# name of the type and index in elasticsearch
Post._doc_type.name
Post._doc_type.index
# the raw Mapping object
Post._doc_type.mapping
# the optional name of the parent type (if defined)
Post._doc_type.parent
Post._doc_type.refresh()
```

删除文档：

```python
first = Post.get(id=42)
first.delete()
```

#### 4 Search

在文档类型中搜索，使用 search 类方法：

```python
# by calling .search we get back a standard Search object
s = Post.search()
# the search is already limited to the index and doc_type of our document
s = s.filter('term', published=True).query('match', title='first')
results = s.execute()
# when you execute the search the results are wrapped in your document class (Post)
for posts in results:
    print(post.meta.score, post.title)
```

也可以构建如下：

```python
s = Search()
s = s.doc_type(Post)
```

也可以用标准的文档类型组合文档类。也可以通过使用 Search 对象的 suggest 方法来得到 Suggestion。

```python
s = Post.search()
s = s.suggest('title_suggestions', 'pyth', completion={'field': 'title_suggest'})

# you can even execute just the suggestions via the _suggest API
suggestions = s.execute_suggest()

for result in suggestions.title_suggestions:
    print('Suggestions for %s:' % result.text)
    for option in result.options:
        print('  %s (%r)' % (option.text, option.payload))
```

class Meta 的选项：
+ `doc_type`: 在 ElasticSearch 中的 doc_type 的名称，默认的，这会是类的名称。
+ `index`：文档的默认缩影，默认为空， 但是 get 和 save 需要一个明确的 index 参数。
+ `using`： 默认的 use 的别名连接。默认为 `default`
+ `mapping`：Mapping 类的实例，

所有 Meta 类的属性都是 MetaField 的实例。名字参数自定义如下：

```
class Post(DocType):
    title = String()

    class Meta:
        all = MetaField(enabled=False)
        parent = MetaField(type="blog")
        dynamic = MetaField("strict")
```

#### 5 Index
这个类的职责是为元数据在 ES 中维护一个相关的索引可以在同一时刻自定义多个 mapping。在前移时非常有用：

```python
from elasticsearch_dsl import Index, DocType, String

blogs = Index('blogs')

# define custom settings
blogs.settings(
    number_of_shards=1,
    number_of_replicas=0
)

# define aliases
blogs.aliases(
    old_blogs={}
)

# register a doc_type with the index
blogs.doc_type(Post)

# can also be used as class decorator when defining the DocType
@blogs.doc_type
class Post(DocType):
    title = String()

# delete the index, ignore if it doesn't exist
blogs.delete(ignore=404)

# create the index in elasticsearch
blogs.create()

```

使用 clone 方法可以创建特殊的副本：

```python
blogs = Index('blogs', using='production')
blogs.settings(number_of_shards=2)
blogs.doc_type(Post)

# create a copy of the index with different name
company_blogs = blogs.clone('company-blogs')

# create a different copy on different cluster
dev_blogs = blogs.clone('blogs', using='dev')
# and change its settings
dev_blogs.setting(number_of_shards=1)
```
