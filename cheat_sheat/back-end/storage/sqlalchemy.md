
### 数据库基础

+ 索引类型：BTree索引，哈希索引，全文索引
+ MySQL 中的数据存储引擎： MyISAM、InnoDB
+ 索引架构的实现：聚集索引，非聚集索引，覆盖索引

索引就是数据库系统维护的满足特定查找算法的数据结构，这种数据结构以某种方式引用数据，实现高效的查找。

+ B-Tree：
  - d 为一个大于 1 的正整数，成为 B-Tree 的度。
  - h 为 B-Tree 的高度
  - 每个非叶子节点由 n-1 个 key 和 n 个指针组成，其中 d <= n <= 2*d
  - 每个叶子节点都有相同的深度 h，平衡性满足
+ B+Tree:
  - 每个节点上组多有 2d 个指针
  - 内部节点不存储 data，因而叶节点和内节点大小不同。
+ 带有顺序访问指针的 B+Tree

索引可能很大，不能全部存储在内存中，因而索引往往以索引文件的形式存储在磁盘上，索引的结构组织要尽可能地减少磁盘 IO 的次数。
B 树的 d 一般很大，因而 h 一般非常小，这样就减少了磁盘读取次数。

+ MyISAM 索引的B+Tree 叶节点的 data 只存放数据记录的地址。主索引和辅助索引没有区别。称之为非聚集索引
+ InnoDB 叶节点的 data 域中保存完整的数据记录，因而 InnoDB 中的表数据文件本身就是按照 B+Tree 组织的一个索引结构。
+ InnoDB 的辅助索引叶节点的 data 存储表的主键的值，而不是地址。
+ InnoDB 按照主键索引十分高效，但是辅助索引需要搜索两遍索引。

建议：
+ 不建议使用过长的字段作为主键-> 会使辅助索引变得过大
+ 不要使用非单调的字段作为主键，因为 InnoDB 数据文件本身是一棵 B+Tree。非单调的主键会在插入新纪录时频繁分裂调整内部节点。


### 版本检查

```python
import sqlalchemy
sqlalchemy.__version__
```

### 连接

```python
from sqlalchemy import create_engine
engine = create_engine('sqlite:///:memory:', echo=True)

### 定义映射
from sqlalchemy.ext.declarative import declarative_base
Base = declarative_base()

from sqlalchemy import Column, Integer, String

class User(Base):
     __tablename__ = 'users'

     id = Column(Integer, primary_key=True)
     name = Column(String)
     fullname = Column(String)
     password = Column(String)

     def __repr__(self):
        return "<User(name='%s', fullname='%s', password='%s')>" % (
                             self.name, self.fullname, self.password)
```

### 定义范式

```python
>>> User.__table__ 
Table('users', MetaData(bind=None),
            Column('id', Integer(), table=<users>, primary_key=True, nullable=False),
            Column('name', String(), table=<users>),
            Column('fullname', String(), table=<users>),
            Column('password', String(), table=<users>), schema=None)

>>> Base.metadata.create_all(engine)
SELECT ...
PRAGMA table_info("users")
()
CREATE TABLE users (
    id INTEGER NOT NULL, name VARCHAR,
    fullname VARCHAR,
    password VARCHAR,
    PRIMARY KEY (id)
)
()
COMMIT
```

### 创建Mapped Class的实例

```python
ed_user = User(name='ed', fullname='Ed Jones', password='edspassword')
ed_user.name ＃ ed
```

### 创建会话Session

```python
from sqlalchemy.orm import sessionmaker
Session = sessionmaker(bind=engine)

或者
Session = sessionmaker()
Session.configure(bind=engine)

最后得到可用的会话对象：
Session.configure(bind=engine)
session = Session()
```


### 加入与更新数据

```python
ed_user = User(name='ed', fullname='Ed Jones', password='edspassword')
session.add(ed_user)
our_user = session.query(User).filter_by(name='ed').first()
ed_user is our_user  ＃ True

直接将一个列表加入到数据库中
>>> session.add_all([
...     User(name='wendy', fullname='Wendy Williams', password='foobar'),
...     User(name='mary', fullname='Mary Contrary', password='xxg527'),
...     User(name='fred', fullname='Fred Flinstone', password='blah')])
```

### 回滚

```python
session.rollback()
fake_user in session  ＃ False
```

### 查询语句

+ order_by语句

```python
for instance in session.query(User).order_by(User.id):
     print(instance.name, instance.fullname)
```

+ 有限查询

```python
for name, fullname in session.query(User.name, User.fullname):
     print(name, fullname)
```

+ 元组查询

```python
for row in session.query(User, User.name).all():
    print(row.User, row.name)
```

+ 

```python
for row in session.query(User.name.label('name_label')).all():
    print(row.name_label)
```

+ 范围查询

```python
for u in session.query(User).order_by(User.id)[1:3]:
    print(u)
```
  
+ 过滤

```python
for name, in session.query(User.name).\
             filter_by(fullname='Ed Jones'):
    print(name)

for name, in session.query(User.name).\
             filter(User.fullname=='Ed Jones'):
    print(name)
```

+ 常用的过滤操作

```
equals:

not equals:

LIKE:

IN:

NOT IN:

IS NULL:

IS NOT NULL:

AND:

OR:

MATCH:
```

### Events

```python
from sqlalchemy.event import listen
from sqlalchemy.pool import Pool

def my_on_connect(dbapi_con, connection_record):
    print("New DBAPI connection:", dbapi_con)

listen(Pool, 'connect', my_on_connect)


from sqlalchemy.event import listens_for
from sqlalchemy.pool import Pool

@listens_for(Pool, "connect")
def my_on_connect(dbapi_con, connection_record):
    print("New DBAPI connection:", dbapi_con)

```
### 

```python
from sqlalchemy.event import listens_for
from sqlalchemy.pool import Pool
```

### Flask-SQLalchemy 可以识别的扩展清单

[来源](http://www.pythondoc.com/flask-sqlalchemy/config.html)

+ `SQLALCHEMY_DATABASE_URI`: 用于连接数据的数据库
+ `SQLALCHEMY_BINDS`: 引用绑定，使得Flask-SQLAlchemy 可以容易地连接到多个数据库。
+ `SQLALCHEMY_ECHO`: 如果设置成 True，SQLAlchemy 将会记录所有 发到标准输出(stderr)的语句，这对调试很有帮助。
+ `SQLALCHEMY_RECORD_QUERIES`: 可以用于显式地禁用或者启用查询记录。查询记录在调试或者测试模式下自动启用。
+ `SQLALCHEMY_NATIVE_UNICODE`: 可以用于显式地禁用支持原生的 unicode。这是 某些数据库适配器必须的（像在 Ubuntu 某些版本上的 PostgreSQL），当使用不合适的指定无编码的数据库 默认值时。
+ `SQLALCHEMY_POOL_SIZE`: 数据库连接池的大小。默认是数据库引擎的默认值 （通常是 5）。
+ `SQLALCHEMY_POOL_TIMEOUT`: 指定数据库连接池的超时时间。默认是 10。
+ `SQLALCHEMY_POOL_RECYCLE`: 自动回收连接的秒数。这对 MySQL 是必须的，默认 情况下 MySQL 会自动移除闲置 8 小时或者以上的连接。 需要注意地是如果使用 MySQL 的话， Flask-SQLAlchemy 会自动地设置这个值为 2 小时。
+ `SQLALCHEMY_MAX_OVERFLOW`: 控制在连接池达到最大值后可以创建的连接数。当这些额外的 连接回收到连接池后将会被断开和抛弃。
+ `SQLALCHEMY_TRACK_MODIFICATIONS`: 如果设置成 True (默认情况)，Flask-SQLAlchemy 将会追踪对象的修改并且发送信号。