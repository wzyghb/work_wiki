
graphql 是一种新的 api 表现形式，相比于 restful api，其优点是更加灵活(个人见解)。

[官网主页](http://graphql.org/)
[github 教程](https://github.com/facebook/graphql)

graphql api 的学习主要包括:
+ 查询语句：GraphQL query language
+ 类型系统：GraphQL schema language
+ GraphQL 服务是如何工作的
+ 使用 GraphQL 解决常见问题的最佳实践

GraphQL 主要关键字：

| 关键字 | 说明 |
| ---: | ---: |
| query | 查询 |
| mutation | 修改 |
| type | 类型 |


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

1. 使用 $variableName 替代查询语句中的静态名字。
2. 声明 $variableName 为查询可以接受的变量。
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

### Operation name

上面的例子中，我们使用简要的语法，忽略了 query 关键字和 query 的名字，在真正的产品中应该使用这些增加程序的可读性。

GraphQL 查询和修改的名字、fragment 的名字在 debugging 时非常重要。

### Directives 指令

Directives 命令可以绑定到 field 或者 fragment 上，决定服务端是否返回指定的部分。只有两种基本的 directives：

+ @include(if: Boolean) 如果 if 参数为 true 则包含指定内容。
+ @skip(if: Boolean) 如果 if 参数为 true 则跳过指定的内容。

例子表示如下：

查询构建：
```
query Hero($episode: Episode, $withFriends: Boolean!) {
  hero(episode: $episode) {
    name
    friends @include(if: $withFriends) {
      name
    }
  }
}
```

查询变量：
```json
{
  "episode": "JEDI",
  "withFriends": true
}
```

通过使用 directives 减少字符串的拼接，使用 server 端一些实验性的特征。

### Mutations

所有会导致写的操作都应该以 mutation 明确地表示出来。更新 object 后，应该将 object 的新状态传递回来。

查询的例子：
```
mutation CreateReviewForEpisode($ep: Episode!, $review: ReviewInput!) {
  createReview(episode: $ep, review: $review) {
    stars
    commentary
  }
}
```

用 json 传入参数：
```json
{
  "ep": "JEDI",
  "review": {
    "stars": 5,
    "commentary": "This is a great movie!"
  }
}
```

返回结果如下：
```json
{
  "data": {
    "createReview": {
      "stars": 5,
      "commentary": "This is a great movie!"
    }
  }
}
```

+ 注意 createReview 使用 stars 和 commentary 域。这使得我们在一个请求中同时完成了对象的更新以及新对象的查询。
+ 注意 review 变量是 input object type.

#### Multiple fields in mutations

query 和 mutations 的区别：

query 查询一个 feild 是并行的，而 mutation field 则是序列的，一个接着另一个。

如果我们在一次查询时发送两个 incrementCredits 修改，那么第一个修改会保证在第二个修改开始前完成，依次避免 race condition 的出现。

### Inline Fragments

类似于其他的类型系统，GraphQL 格式包括了定义 interface 和 union 类型的能力。如果需要查询一个返回 interface 或者 union 类型的域，你需要使用 inline
fragments 来访问数据潜在的固有类型。使用的例子如下：

查询语句：
```
query HeroForEpisode($ep: Episode!) {
  hero(episode: $ep) {
    name
    ... on Droid {
      primaryFunction
    }
    ... on Human {
      height
    }
  }
}
```

传入参数的 json：
```json
{
  "ep": "EMPIRE"
}
```

返回结果：
```json
{
  "data": {
    "hero": {
      "name": "Luke Skywalker",
      "height": 1.72
    }
  }
}
```

如果传入的参数是：
```json
{
  "ep": "JEDI"
}
```

那么返回的结果是：
```json
{
  "data": {
    "hero": {
      "name": "R2-D2",
      "primaryFunction": "Astromech"
    }
  }
}
```

Human 对象和 Droid 都继承了 Charater 对象，共有 field 为 name，Human 有 height 对象，而 Droid 对象有 primaryFunction 的 field。

实际上 Named field 也可以以相同的方法来使用，但是 Named Fragment 总是会有一个附加的类型。

#### meta fields

用途：有时候你不知道 GraphQL 服务会返回什么样的数据给 client，GraphQL 可以使用 __typename，一个 meta field，这样所有返回的结果将会包括对象的 Type。

例子，请求如下：

```
{
  search(text: "an") {
    __typename
    ... on Human {
      name
    }
    ... on Droid {
      name
    }
    ... on Starship {
      name
    }
  }
}
```

返回结果如下：
```json
{
  "data": {
    "search": [
      {
        "__typename": "Human",
        "name": "Han Solo"
      },
      {
        "__typename": "Human",
        "name": "Leia Organa"
      },
      {
        "__typename": "Starship",
        "name": "TIE Advanced x1"
      }
    ]
  }
}
```

graphql 还提供了很多的 metafield，参见 [Introspection](http://graphql.org/learn/introspection/)

## Schemas 和 Types

每个 GraphQL 服务定义了类型的集合，完整地描述了查询服务时可能的数据集合。我们使用 GraphQL schema language 来定义类型。

### 对象类型和域

```
type Character {
  id: ID!
  name: String!
  appearsIn: [Episode]!
  length(unit: LengthUnit = METER): Float
}
```

说明：

+ Character： GraphQL object type
+ name 和 appearsIn：field in Character type
+ String: built-in scalar types
+ String!: non-nullable
+ [Episode]! Episode 对象的数组
+ 每个 field 都可以零个或者多个参数，可以设定默认值

### Query 和 Mutation types

在 Schema 中的定义：
```
schema {
  query: Query
  mutation: Mutation
}
```

注意，query 和 mutation 类型是 schema 的进入点，除此之外和其他的 GraphQL 对象类型没有差别。

### Scalar types

scalar type 的查询的叶节点。GraphQL 定义了下面几种 Scalar type：

+ Int: 32 位整数
+ Float: 有符号双进度浮点数
+ String: UTF-8 字符序列
+ Boolean: true or false
+ ID: 代表唯一标识，和 String 一样，但是是 not human readable 的。
+ Date: 

### Enumeration

+ 验证所有该类型的参数的值在允许的范围内
+ type system 会知道这个 field 的取值是有限的。

例子：
```
enum Episode {
  NEWHOPE
  EMPIRE
  JEDI
}
```

### Lists 和 Non-Null

非空的几种组合形式：

```
myField: [String!]
myField: [String]!
```

### Interfaces

定义：
```
interface Character {
  id: ID!
  name: String!
  friends: [Character]
  appearsIn: [Episode]!
}
```

使用：
```
type Human implements Character {
  id: ID!
  name: String!
  friends: [Character]
  appearsIn: [Episode]!
  starships: [Starship]
  totalCredits: Int
}

type Droid implements Character {
  id: ID!
  name: String!
  friends: [Character]
  appearsIn: [Episode]!
  primaryFunction: String
}
```

在一次查询时，若可能同时返回 Human 和 Droid，一般需要使用 inline fragments。

### Union types

例子：
```
union SearchResult = Human | Droid | Starship
```

注意 Union type 的 member 必须是固有对象类型，不能通过 interface 或者其他 unions 来构建新的 union。
查询 union 类型时，需要使用 conditional fragment 来构建查询：

```
{
  search(text: "an") {
    ... on Human {
      name
      height
    }
    ... on Droid {
      name
      primaryFunction
    }
    ... on Starship {
      name
      length
    }
  }
}
```

查询结果：

```
{
  "data": {
    "search": [
      {
        "name": "Han Solo",
        "height": 1.8
      },
      {
        "name": "Leia Organa",
        "height": 1.5
      },
      {
        "name": "TIE Advanced x1",
        "length": 9.2
      }
    ]
  }
}
```

### input types

前面已经使用 Scalar type 作为 field 的参数，比如 enum 或者 strings，实际上也可以传递复杂的对象，这在做
mutation 时尤其重要，可以将完整的对象传递来进行创建。在 GraphQL Schema 语言中，输入类型和正常的对象类型非常类似，只是使用了关键字 input。

例子表示如下：
```
input ReviewInput {
  stars: Int!
  commentary: String
}
```

在 Mutation 中使用的例子：

```
mutation CreateReviewForEpisode($ep: Episode!, $review: ReviewInput!) {
  createReview(episode: $ep, review: $review) {
    stars
    commentary
  }
}
```
参数输入 json：
```
{
  "ep": "JEDI",
  "review": {
    "stars": 5,
    "commentary": "This is a great movie!"
  }
}
```

返回的结果表示如下：
```
{
  "data": {
    "createReview": {
      "stars": 5,
      "commentary": "This is a great movie!"
    }
  }
}
```

在 schema 中不能混杂 input 和 output 的 schema。

## Validation

不合法的查询：
+ fragment 不能够引用其自身。
+ 非 scalar 类型需要规定其 field

使用有名称的 fragment 查询 union object 的 field 字段的例子：

```
{
  hero {
    name
    ...DroidFields
  }
}

fragment DroidFields on Droid {
  primaryFunction
}
```

查询结果：
```json
{
  "data": {
    "hero": {
      "name": "R2-D2",
      "primaryFunction": "Astromech"
    }
  }
}
```

## Execution

GraphQL 的执行需要与之配套的类型系统，下面是一个执行的例子：

类型系统定义：

```
type Query {
  human(id: ID!): Human
}

type Human {
  name: String
  appearsIn: [Episode]
  starships: [Starship]
}

enum Episode {
  NEWHOPE
  EMPIRE
  JEDI
}

type Starship {
  name: String
}
```

定义一个查询语句如下：

```
{
  human(id: 1002) {
    name
    appearsIn
    starships {
      name
    }
  }
}
```

返回结果如下：

```json
{
  "data": {
    "human": {
      "name": "Han Solo",
      "appearsIn": [
        "NEWHOPE",
        "EMPIRE",
        "JEDI"
      ],
      "starships": [
        {
          "name": "Millenium Falcon"
        },
        {
          "name": "Imperial shuttle"
        }
      ]
    }
  }
}
```

可以认为 GraphQL 查询中的每一个域是一个函数或者方法，将之前的类型转化为另一种类型。实际上这也是 GraphQL 的工作方式，每个 field 在后台都对应一个
函数称为 resolver，当一个 field 被执行时，对应的 resolver 会被调用，产生下一个值。

如果 field 是一个 scalar value，那么执行将会完成，如果一个 field 是一个对象，那么 query 会继续查找这个对象的 field，如此迭代直到 scalar values。

### Root Fields & resolvers

GraphQL 服务器将所有可能的 entry point 表示为 GraphQL API，通常称为 Root type 或者 Query Type。 **如何理解？**

在上面的查询中，human field 接受一个参数 id，因而对应的 resolver 函数会访问数据库，并构建一个 Human 对象返回。

```
Query: {
  human(obj, args, context) {
    return context.db.loadHumanByID(args.id).then(
      userData => new Human(userData)
    )
  }
}
```

resolver 函数接受三个参数：
+ **obj**：以前的对象，在root Query type 中通常不使用。
+ **args**：在 GraphQL 查询中传递给 field 的参数。
+ **context**：传递给每个 resolver 的值，包括当前登陆的用户，可以访问的数据库等。

### 异步 resolvers

例子：
```javascript
human(obj, args, context) {
  return context.db.loadHumanByID(args.id).then(
    userData => new Human(userData)
  )
}
```

### resolvers 的细节

```javascript
Human: {
  name(obj, args, context) {
    return obj.name
  }
}
```

GraphQL Server 由 type system 驱动，在这种情况下，解析名字非常直接，name 的 resolver 函数调用 obj 参数是 new Human 对象。GraphQL libraries 还提供
了类似的机制，默认直接从 obj 中读取并且返回。

### 强制 Scalar

因为具有类型系统，因而 GraphQL 能将一些数据自动转化为需要的类型（比如使用数字存储的 enum 类型）。

### List resolvers

例子：
```javascript
Human: {
  starships(obj, args, context) {
    return obj.starshipIDs.map(
      id => context.db.loadStarshipByID(id).then(
        shipData => new Starship(shipData)
      )
    )
  }
}
```

此时这个 field 的 resolver 不是返回一个 Promise，而是返回 Promise 的列表。GraphQL 会等待这些 Promise 运行完毕，最终返回 objects 的列表。

### Producing the result

当所有的 field 都完成解析，结果会议 key-value 的形式返回，其 key 是 field 的名称，而解析结果则是 value，这会从 root query type 解析到 leaf fields of the query。
最终将 json 结果返回请求者。
例子：

```
{
  human(id: 1002) {
    name
    appearsIn
    starships {
      name
    }
  }
}
```

返回的结果：

```
{
  "data": {
    "human": {
      "name": "Han Solo",
      "appearsIn": [
        "NEWHOPE",
        "EMPIRE",
        "JEDI"
      ],
      "starships": [
        {
          "name": "Millenium Falcon"
        },
        {
          "name": "Imperial shuttle"
        }
      ]
    }
  }
}
```

## Introspection 反射

基本作用：向 GraphQL schema 查询那些 query 他可以支持。

