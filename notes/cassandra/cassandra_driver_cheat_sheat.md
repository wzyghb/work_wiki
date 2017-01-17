
## get started

### 连接到 cassandra

```python
from cassandra.cluster import Cluster

# 连接
cluster = Cluster() // 1 默认连接到 127。0.0.1
cluster = Cluster(['192.168.0.1', '192.168.0.2']) // 2
cluster = Cluster(['10.1.1.3', '10.1.1.4', '10.1.1.5'], load_balancing_policy=DCAwareRoundRobinPolicy(local_dc="US_EAST"), port=9042) // 3

session = cluster.connection()

session.set_keyspace("users")   // 1
session.execute("USER users")   // 2

session = cluster.connection("mykeyspace")
```

### 执行 CQL 查询语句

同步执行：

```python
# 执行 CQL
rows = session.execute('SELECT name, age, email FROM users')
for user_row in rows:
    print user_row.name, user_row.age, user_row.email

# 执行 CQL 并传入参数
session.execute(
    """
    INSERT INTO users (name, credits, user_id)
    VALUES (%s, %s, %s)
    """,
    ("John O'Reilly", 42, uuid.uuid1())
)

```

异步执行： 返回一个 ResponseFuture 对象
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


### 设置一致性层级

```
from cassandra import ConsistencyLevel
from cassandra.query import SimpleStatement

query = SimpleStatement(                            # 将查询封装在一个 SimpleStatement 中
    "INSERT INTO users (name, age) VALUES (%s, %s)",
    consistency_level=ConsistencyLevel.QUORUM)      # 在语句层级设置一致性等级
session.execute(query, ('John', 42))
```

+ 准备语句

所有的 prepare 语句会被 cassandra 解析，并在之后等待使用。使用时仅需要将需要的参数发送并绑定，不需要再进行解析。所以会接收 CPU 利用。

```
user_lookup_stmt = session.prepare("SELECT * FROM users WHERE user_id=?")   # 注意此处的 ? 是一个占位符号，返回一个 PreparedStatement

users = []
for user_id in user_ids_to_query:
    user = session.execute(user_lookup_stmt, [user_id])
    users.append(user)
```

+ 在准备语句中设定 ConsistencyLevel

```python
from cassandra import ConsistencyLevel

cluster = Cluster()
session = cluster.connect("mykeyspace")
user_lookup_stmt = session.prepare("SELECT * FROM users WHERE user_id=?")
user_lookup_stmt.consistency_level = ConsistencyLevel.QUORUM

# these will both use QUORUM
user1 = session.execute(user_lookup_stmt, [user_id1])[0]
user2 = session.execute(user_lookup_stmt, [user_id2])[0]

# 在 PrepareStatement 语句中绑定参数生成 BoundStatement 语句
user3_lookup = user_lookup_stmt.bind([user_id3])
user3_lookup.consistency_level = ConsistencyLevel.ALL
user3 = session.execute(user3_lookup)
```

## Object Mapper
