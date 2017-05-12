
## 1 [diesel](https://github.com/diesel-rs/diesel)

[postgres 数据库命令参考](https://mozillazg.github.io/2014/06/hello-postgresql.html)
Diesel 由两部分组成，一部分是在 cargo 中指定，需要安装的依赖包，另一部分则是一些 cli 工具。

### 1. 依赖包如下：
```toml

[dependencies]
diesel = { version = "0.11.0", features = ["postgres"] }
diesel_codegen = { version = "0.11.0", features = ["postgres"] }
dotenv = "0.8.0"

# 使用 sqlite
diesel = { git = "https://github.com/diesel-rs/diesel", features = ["sqlite", "large-tables"] }
diesel_codegen = { git = "https://github.com/diesel-rs/diesel", features = ["sqlite"] }
r2d2 = "0.7.2"
r2d2-diesel = { git = "https://github.com/king6cong/r2d2-diesel" }
libsqlite3-sys = { version = "=0.8.0", features = ["bundled"] }
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

```bash
diesel migration run
```

使用正确的 `down.sql` 可以实现下面的 redoing 如下：

```bash
diesel migration redo
```

### 5. 创建数据库的连接

示例代码，创建一个数据库连接池(使用 sqlite)：

```rust
extern crate diesel;
extern crate diesel_codegen;
extern crate r2d2;
extern crate r2d2_diesel;
extern crate dotenv;

use std::path::Path;
use diesel::prelude::*;
use diesel::sqlite::SqliteConnection;
use r2d2_diesel::ConnectionManager;
use dotenv::dotenv;

// 数据库的路径
let path: &str = "xxx\addd\addd";
let db_name: &str = "xxx.db";
let database_url = Path::new(&path).join(&name).to_str().ok_or(Error::from("failed to get url to db!"));

// 连接池的配置和管理
let config = r2d2::Config::default();
let manager = ConnectionManager::<SqliteConnection>::mew(database_url);
let pool = r2d2::Pool::new(config, manager).expect("failed to create pool");

// ??? 待明确原因
embed_migrations!();
embedded_migrations::run(&*pool.get().unwrap()).unwrap();

// 从数据库中获得一个数据库的连接
let conn = pool.get().unwrap();
```

## 2 [ws-rs](https://github.com/housleyjk/ws-rs)

### 使用 ws 的开发版本
```
[dependencies]
ws = { version = "*", git = "https://github.com/housleyjk/ws-rs"}
```

### simple use

+ Server
```rust
extern crate ws;

use ws::listen;

fn main() {
  listen("127.0.0.1:3012", |out| {  // 也可以接受一个 Factory
      move |msg| {
         out.send(msg)
      }
  }).unwrap()
} 
```

+ client
```rust
extern crate ws;

use ws::{connect, CloseCode};

fn main() {
  connect("ws://127.0.0.1:3012", |out| {
      out.send("Hello WebSocket").unwrap();

      move |msg| {
          println!("Got message: {}", msg);
          out.close(CloseCode::Normal)
      }
  }).unwrap()
} 
```
上面会封装为一个 mio 的 EventLoop，创建并在当前线程中运行一个 WebSocket。这些都是阻塞的函数，只有
启动的 websocket 断开后才会返回。


## 3 [iron](http://ironframework.io/doc/iron/)
+ [router](https://github.com/iron/router)
+ [Chain]()
+ [Key]()
+ [handlebars_iron]()  模板文件
+ [persistent](http://ironframework.io/doc/persistent/) Middleware 在 request 之间共享数据。


## 4 [tokio](https://tokio.rs/)

### 1 [future](https://tokio.rs/docs/getting-started/futures/)

future 的使用场景：
1. 数据库查询
2. 一个 rpc 的远程调用
3. 超时
4. 一个长时间运行的 CPU 密集任务
5. 从 socket 读取一些字节数据


# reference
+ [rustwebapp](https://github.com/superlogical/rustwebapp)
+ [web docker](https://github.com/clementmiao/website-rocket)
+ [thanks](https://github.com/rust-lang-nursery/thanks)
+ [rustironreact](https://github.com/cmsd2/rust-iron-react-webpack)
