
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
2. set null ：在父表上 delete/update 时，将子表的记录列设置为 null，注意子表的外键列不能为 not null。
3. no action：如果子表中有匹配记录，则不允许对父表进行候选键进行 update、delete 操作，一般都是这个操作。

## 单列索引和联合索引

相比于单列索引，联合索引限制了 `where` 子句的查询顺序，以更加高效地使用索引。

[参考资料](https://my.oschina.net/857359351/blog/658668)
