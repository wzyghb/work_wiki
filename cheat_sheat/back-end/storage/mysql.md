# mysql 相关的记录

## 类映射继承关系

### 1. `single table inheritance` 多个类型由一个表表示

### 2.  `concrete table inheritance` 每个类型由一个独立的表来表示

### 3.  `joined table inheritance` 继承关系和依赖表相关，每个类都有他自己的表来表示，和这个类相关的。

例子：

```python
class Employee(Base):
    __tablename__ = 'employee'
    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    type = Column(String(50))

    __mapper_args__ = {
        'polymorphic_identity':'employee',
        'polymorphic_on':type
    }
```

此处 type column 是 discriminator (标识符)，标识着这一行代表着哪个类。 discriminator 可以是任意类型，但一般都是整数或者字符串类型。
目前只能设置一列作为 discriminator，Cascading 形式的多态 columns 是不允许的。

## 外键

维护数据库中两张表的数据一致性。约束的模式有：

1. cascade 级联：在父表上 update/delete 记录时，同步 update/delete 掉子表的匹配记录。
1. set null ：在父表上 delete/update 时，将子表的记录列设置为 null，注意子表的外键列不能为 not null。
1. no action：如果子表中有匹配记录，则不允许对父表进行候选键进行 update、delete 操作，一般都是这个操作。

## 单列索引和联合索引

相比于单列索引，联合索引限制了 `where` 子句的查询顺序，以更加高效地使用索引。

[参考资料](https://my.oschina.net/857359351/blog/658668)

### 结论

1. 联合索引上会有一个mysql索引最左匹配原则，但是如果联合索引的第一个列不在where条件语句中，并且所查询的列其中有的是没有建立索引的，那么这个联合索引就是无效的。
1. 如果使用联合索引，那么where条件也要尽量根据联合索引的顺序来，如果不按照顺序来，索引也同样会用到，但是在执行前，SQL优化器也会将条件调整为联合索引的顺序。

## SQLALCHEMY 使用总结

### `__table_args__` 设置

```python
class UDFMixin(object):
    __table_args__ = {
        'mysql_engine': 'InnoDB',
        'mysql_charset': 'utf8',
    }

class Xxxx(db.Model, UDFMixin)
    xxx = xxxx.xxx()
    __table_args__ = (
        UniqueConstraint(user_id, official_user_id, name='uniq_official_user_id_ref'),
        UDFMixin.__table_args__
    )
```

### `__table__` 使用映射快速读取数据库

```python
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
Base.metadata.reflect(some_engine)

class User(Base):
    __table__ = metadata.tables['user']

class Address(Base):
    __table__ = metadata.tables['address']
```

### 一种等价的 Model 定义方法

```python
class MyClass(Base):
    __table__ = Table('my_table', Base.metadata,
        Column('id', Integer, primary_key=True),
        Column('name', String(50))
    )
```

## null 索引的问题

### 要尽量避免 NULL 

+ NULL 是 mysql 一种值的类型，会占用空间。NULL 和空值不等价（如 string 中的 '')
+ NULL 是一个值，所以会在查询时进行比较，因而对效率有一定的影响。
+ 多列联合索引时，如果某个列为 NULL，那么整个联合索引都不会被创建。
+ MySQL 使用 B+ 树创建索引，null 没法实现 == 操作
+ MYSQL 中建议列属性尽可能为 NOT NULL

要尽可能地把字段定义为 NOT NULL。即使应用程序无须保存 NULL（没有值），也有许多表包含了可空列（Nullable Column）,这仅仅是因为它为默认选项。除非真的要保存 NULL，否则就把列定义为 NOT NULL。 

MySQL难以优化引用了可空列的查询，它会使索引、索引统计和值更加复杂。可空列需要更多的储存空间，还需要在MySQL内部进行特殊处理。当可空列被索引的时候，每条记录都需要一个额外的字节，还可能导致 MyISAM 中固定大小的索引(例如一个整数列上的索引)变成可变大小的索引。 

即使要在表中储存「没有值」的字段，还是有可能不使用 NULL 的。考虑使用 0、特殊值或空字符串来代替它。 

把 NULL 列改为 NOT NULL 带来的性能提升很小，所以除非确定它引入了问题，否则就不要把它当作优先的优化措施。然后，如果计划对列进行索引，就要尽量避免把它设置为可空。 
