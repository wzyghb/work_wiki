
graphql 是一种新的 api 表现形式，相比于 restful api，其优点是更加灵活(个人见解)。

graphql api 的学习主要包括:
+ 查询语句
+ 类型系统
+ GraphQL 服务是如何工作的
+ 使用 GraphQL 解决常见问题的最佳实践

## 查询和更改

### Fields

GraphQL 可以查询对象特定的域，例子如下：

```
{
  hero {
    name
  }
}
```

结果：

```json
{
  "data": {
    "hero": {
      "name": "R2-D2"
    }
  }
}
```

注意，查询结果具有和查询语句类似的 shape。

### Arguments 

graphql 可以给 field 传入参数：

```
{
  human(id: "1000") {
    name
    height
  }
}
```

查询结果：

```json
{
  "data": {
    "human": {
      "name": "Luke Skywalker",
      "height": 1.72
    }
  }
}
```

甚至可以传入单位：

```
{
  human(id: "1000") {
    name
    height(unit: FOOT)
  }
}
```

得到结果如下：

```json
{
  "data": {
    "human": {
      "name": "Luke Skywalker",
      "height": 5.6430448
    }
  }
}
```

graphql 的 schemas 和 type 定义参见后文。

### Aliases

注意到上面带参数的查询中，返回结果中对象匹配了查询 field 的名字作为键，因而若使用多个查询参数同时从查询，那么会产生 key 的冲突。
为了解决这种情况，因而有 Aliases 定义如下：

```
{
  empireHero: hero(episode: EMPIRE) {
    name
  }
  jediHero: hero(episode: JEDI) {
    name
  }
}
```

返回结果如下：

```json
{
  "data": {
    "empireHero": {
      "name": "Luke Skywalker"
    },
    "jediHero": {
      "name": "R2-D2"
    }
  }
}
```

### Fragments

查询片段，可以复用，减少冗余查询代码。

例子定义如下：

```
{
  leftComparison: hero(episode: EMPIRE) {
    ...comparisonFields
  }
  rightComparison: hero(episode: JEDI) {
    ...comparisonFields
  }
}

fragment comparisonFields on Character {
  name
  appearsIn
  friends {
    name
  }
}
```

得到结果如下：

```json
{
  "data": {
    "leftComparison": {
      "name": "Luke Skywalker",
      "appearsIn": [
        "NEWHOPE",
        "EMPIRE",
        "JEDI"
      ],
      "friends": [
        {
          "name": "Han Solo"
        },
        {
          "name": "Leia Organa"
        },
        {
          "name": "C-3PO"
        },
        {
          "name": "R2-D2"
        }
      ]
    },
    "rightComparison": {
      "name": "R2-D2",
      "appearsIn": [
        "NEWHOPE",
        "EMPIRE",
        "JEDI"
      ],
      "friends": [
        {
          "name": "Luke Skywalker"
        },
        {
          "name": "Han Solo"
        },
        {
          "name": "Leia Organa"
        }
      ]
    }
  }
}
```

### Variables

使用 Variable 变量需要做三件事：

1. 使用 $variableName 替代查询语句中的静态名字
2. 声明 $variableName 为查询可以接受的变量
3. 单独地传递 variableName: value，一般是通过 json 完成。

查询定义：
```
query HeroNameAndFriends($episode: Episode) {
  hero(episode: $episode) {
    name
    friends {
      name
    }
  }
}
```

```json
{
  "episode": "JEDI"
}
```

结果定义：

```json
{
  "data": {
    "hero": {
      "name": "R2-D2",
      "friends": [
        {
          "name": "Luke Skywalker"
        },
        {
          "name": "Han Solo"
        },
        {
          "name": "Leia Organa"
        }
      ]
    }
  }
}
```

优点：只需要传入一个变量而非构建完整的查询语句。不应当通过用户的输入的解析来构建查询。

#### 变量定义

+ 变量定义的形式为：($episode: Episode)
+ 后面的类型为 scalars、enums、或者输入对象类型。
+ 变量的定义也可以是可选或者必须的(optional or required)。如果对应的 field 需要一个非空的参数，那么变量本身也必须是非空的。

### OPeration name

### Directives

### Mutations

#### Multiple fields in mutations

### Inline Fragments

#### meta fields

## Schemas 和 Types

