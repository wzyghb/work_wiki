
## 1 diesel

[postgres 数据库命令参考](https://mozillazg.github.io/2014/06/hello-postgresql.html)
Diesel 由两部分组成，一部分是在 cargo 中指定，需要安装的依赖包，另一部分则是一些 cli 工具。

### 1. 依赖包如下：
```
[dependencies]
diesel = { version = "0.11.0", features = ["postgres"] }
diesel_codegen = { version = "0.11.0", features = ["postgres"] }
dotenv = "0.8.0"
```

### 2. 安装 cli 工具：
```
cargo install diesel_cli
```

### 3. 通过设定环境变量指定 postgres 数据库的位置:

```
echo DATABASE_URL=postgres://username:password@localhost/diesel_demo > .env
```

### 4. cli 初始化数据库

```
diesel setup
```

如果没有数据库，则创建，并创建一个空的 migrations 文件来管理我们的 schema。
创建一个具体的 migration 如下：

```
diesel migration generate create_posts
```

这会创建两个文件如下：

```
Creating migrations/20160815133237_create_posts/up.sql
Creating migrations/20160815133237_create_posts/down.sql
```

编写用于 migrate 的 SQL 语句如下：

UP SQL:

```sql
CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title VARCHAR NOT NULL,
  body TEXT NOT NULL,
  published BOOLEAN NOT NULL DEFAULT 'f'
)
```

DOWN sql

```sql
DROP TABLE posts
```

应用 migrate 实现如下：

```
diesel migration run
```

使用正确的 `down.sql` 可以实现下面的 redoing 如下：
```
diesel migration redo
```
