# Web Component

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

```bash
cargo install diesel_cli
```

### 3. 通过设定环境变量指定 postgres 数据库的位置:

```bash
echo DATABASE_URL=postgres://username:password@localhost/diesel_demo > .env
```

### 4. cli 初始化数据库

```bash
diesel setup
```

如果没有数据库，则创建，并创建一个空的 migrations 文件来管理我们的 schema。
创建一个具体的 migration 如下：

```bash
diesel migration generate create_posts
```

这会创建两个文件如下：

```bash
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

### 使用中遇到的问题

1. 编译有数据的项目时需要导出 `DATABASE_URL` 环境变量
1. 没有 `POSTGRES_USER` 和 `POSTGRES_PASSWORD` 会在运行时失败

## 2 [ws-rs](https://github.com/housleyjk/ws-rs)

### 使用 ws 的开发版本

```yml
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

## 3 [rocket](https://github.com/SergioBenitez/rocket/)

Rocket provides primitives to build web servers and applications with rust.

### life cycle of a request

1. Routing (incoming HTTP request into native structures)
1. Validation (valide type and guards and forwards the request to error handler)
1. Processing (main business logic of your appliction)
1. Response (generate HTTP Response and sends it to the client)

### Routing

+ static paths
+ dynamic paths
+ path segments
+ forms
+ query string
+ request format specifiers
+ body data

rocket 使用了 attributes，這在 python 中称为 decorators

route handle 定义例子如下：

```rust
#[get("/world")]              // <- route attribute
fn world() -> &'static str {  // <- request handler
    "Hello, world!"
}
```

### Mounting (个人认为类似于 flask 的 blueprint，将 route 挂在到一个子目录下)

`rocket::ignite()` 创建了一个 rocket 实例。

### Namespace 的问题

```rust
mod other {
    #[get("/world")]
    pub fn world() -> &'static str {
        "Hello, world!"
    }
}

use other::world;

fn main() {
  // error[E0425]: cannot find value `static_rocket_route_info_for_world` in this scope
  // error: rocket::ignite().mount("/hello", routes![world]);
  let app = rocket::ignite().mount("/hello", routes![other::world]);
  app.launch();     // starting the server and waiting for request incomming
}
```

### Request

rocket 可以自动地验证:

+ The type of a dynamic path segment.
+ The type of many dynamic path segments.
+ The type of incoming data.
+ The types of query strings, forms, and form values.
+ The expected incoming or outgoing format of a request.
+ Any arbitrary, user-defined security or validation policies.

#### Method

```rust
#[get("/index")]
fn xxx() -> T { ... }

#[post("/")]
#[put("/")]
#[delete("/")]
#[head("/")]
#[patch("/")]
#[options("/")]
```
这些属性定义在 rocket_codegen 中。

+ `HEAD` Requests 是 `GET` 的特殊化
+ 浏览器仅能够发送 `GET` 和 `POST` 请求，因而 rocket 会对请求做进一步的的解析

#### Dynamic Segments

```rust
#[get("/hello/<name>")]
fn hello(name: &RawStr) -> String {
    format!("Hello, {}!", name.as_str())
}
```

dynamic segment 可以是任意实现了 [`FromParam` trait](https://api.rocket.rs/rocket/request/trait.FromParam.html) 的类型。

#### Routing rank

> [rocket route rules](https://rocket.rs/guide/requests/#forwarding)

1. default rank: -4 ~ -1
1. can be manually set to 1 ~ +**
1. [default rank rules](https://rocket.rs/guide/requests/#default-ranking)

#### Multiple Segments

+ 使用 `<param..>`
+ [`FromSegment` trait](https://api.rocket.rs/rocket/request/trait.FromSegments.html)
+ `PathBuf` 实现了 `FromSegment` 而且避免了 path traversal attacks

一个静态文件服务器的实现如下所示：

```rust
#[get("/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/").join(file)).ok()
}
```

#### Format

该概念用于匹配 HTTP 头部的 `Content-Type: application/json`

exapmle code:

```rust
#[post("/user", format = "application/json", data = "<user>")]
fn new_user(user: Json<User>) -> T { ... }

#[get("/user/<id>", format = "application/json")]
fn user(id: usize) -> Json<User> { ... }
```

#### Request Guards

作用：根据请求的数据进行验证，避免 handler 被错误地调用。
所有实现了 [`FromRequest`](https://api.rocket.rs/rocket/request/trait.FromRequest.html) trait 的类型都是一个 request guard。

```rust
#[get("/<param>")]
fn index(param: isize, a: A, b: B, c: C) -> ... { ... }
```

+ param 是 route 的属性，不是 request guard
+ A, B, C 会以顺序进行验证和匹配，一旦某个失败，剩余的将不会再去尝试。

example: 一个简单的认证系统实现

```rust
#[get("/admin")]
fn admin_panel(admin: AdminUser) -> &'static str {
    "Hello, administrator. This is the admin panel!"
}

#[get("/admin", rank = 2)]
fn admin_panel_user(user: User) -> &'static str {
    "Sorry, you must be an administrator to access this page."
}

#[get("/admin", rank = 3)]
fn admin_panel_redirect() -> Redirect {
    Redirect::to("/login")
}
```

#### [Cookies](https://api.rocket.rs/rocket/http/enum.Cookies.html)

example:

```rust
use rocket::http::Cookies;

#[get("/")]
fn index(cookies: Cookies) -> Option<String> {
    cookies.get("message")
        .map(|value| format!("Message: {}", value))
}

/// Remove the `user_id` cookie.
#[post("/logout")]
fn logout(mut cookies: Cookies) -> Flash<Redirect> {
    cookies.remove_private(Cookie::named("user_id"));
    // 注意此处 Flash 的应用
    Flash::success(Redirect::to("/"), "Successfully logged out.")
}
```

##### Private Cookies

> `Cookies::add()` 可以被 Client 看到 cookie 的内容，因而需要 private cookies，其使用 authenticated encryption 算法来进行加密，加密算法保证了 保密、真实和完整，不能被 Client 篡改、检查和伪造。rocket 提供了 `get_private`, `add_private` 和 `remove_private`。

example：

```rust
/// Retrieve the user's ID, if any.
#[get("/user_id")]
fn user_id(cookies: Cookies) -> Option<String> {
    cookies.get_private("user_id")
        .map(|cookie| format!("User ID: {}", cookie.value()))
}

/// Remove the `user_id` cookie.
#[post("/logout")]
fn logout(mut cookies: Cookies) -> Flash<Redirect> {
    cookies.remove_private(Cookie::named("user_id"));
    Flash::success(Redirect::to("/"), "Successfully logged out.")
}
```

##### Secret Key

配置中增加 secret_key 配置项，用于 rocket 生成加密算法。

##### [One at  a time](https://rocket.rs/guide/requests/#one-at-a-time)

#### Body Data

example

```rust
#[post("/", data = "<input>")]
fn new(input: T) -> String { ... }
```

> restrict: `T`: [`FromData`](https://api.rocket.rs/rocket/data/trait.FromData.html) Data Guard

#### Forms

example:

```rust
#[derive(FromForm)]
struct Task {
    complete: bool,
    description: String,
}

#[post("/todo", data = "<task>")]
fn new(task: Form<Task>) -> String { ... }
```

+ Lenient Parsing
+ FieldRenaming
+ FieldValidation

#### Json

example:

```rust
#[derive(Deserialize)]
struct Task {
    description: String,
    complete: bool
}

#[post("/todo", data = "<task>")]
fn new(task: Json<Task>) -> String { ... }
```

#### Streaming

#### [Query Strings](https://rocket.rs/guide/requests/#query-strings)

#### [Error Catches](https://rocket.rs/guide/requests/#error-catchers)

rocket 中是按照错误码来注册错误处理函数的。

example:

```rust
#[error(404)]
fn not_found(req: &Request) -> String { ... }

rocket::ignite().catch(errors![not_found])
```

### Responses

任意实现了 [`Responder` trait](https://api.rocket.rs/rocket/response/trait.Responder.html) 
的类型均可以作为 response 返回。

> HTTP Response 必须由 HTTP Status、headers、body 组成。body 可以是 fixed-sized 或者 streaming。Responders 会根据 `Request` 动态地适应，并返回 `Responder`;

+ `use rocket::response::status` `status::Accepted<String>`
+ `use rocket::response::content` `content::Json<&'static str>`
+ `struct WrappingResponder<R>(R)`

#### example impl of String

```rust
impl Responder<'static> for String {
    fn respond_to(self, _: &Request) -> Result<Response<'static>, Status> {
        Response::build()
            .header(ContentType::Plain)
            .sized_body(Cursor::new(self))
            .ok()
    }
}
```

上面这个实现可以在 `handler` 中直接返回 `&str` or `String` type。

```rust
#[get("/string")]
fn handler() -> &'static str {
    "Hello there! I'm a string!"
}
```

+ `Option<T>` 是一个 wrapping responder，一个 `Option<T>` 仅可当 T 实现了 `Responder` 时可以被返回。当内容可能不存在时，可以返回一个 `Option` 对象.
    ```rust
    // 静态文件服务，不存在时返回 404，存在时返回文件并 200
    #[get("/static/<file..>")]
    fn files(file: PathBuf) -> Option<NamedFile> {
        NamedFile::open(Path::new("static/").join(file)).ok()
    }
    ```
+ `Result` 其最终的效果取决于 `E` 是否实现了 `Responder`, 这意味着 `Responder` 可以在运行时动态地进行选择，如果 `E` 没有实现 `Responder`, 这时候，error 只是简单地打印到 console 中，并返回一个 500 给服务端。

#### Rocket Responders

已经实现的 responders:

+ `Content`
+ `NamedFile`
+ `Redirect`
+ `Stream`
+ `status`
+ `Flash`

#### Streaming

为何需要 streaming？因为你将一个大文件传送给 Client 时，避免占用过大的内存空间。Rocket 提供了 Stream 类型来完成这些操作，可以直接使用 `Read` 类型。

```rust
#[get("/stream")]
fn stream() -> io::Result<Stream<UnixStream>> {
    UnixStream::connect("/path/to/my/socket").map(|s| Stream::from(s))
}
```

#### Json

rocket 在 `rocket_contrib` 库中提供了简便的返回 Json 数据的方法。只需返回 `Json<T>`, 其中 `T` 是一种可以序列化为 Json 的结构。类型 `T` 必须实现 `serde` 中的 `Serialize` Trait。

example:

```rust
use rocket_contrib::Json;

#[derive(Serialize)]
struct Task { ... }

#[get("/todo")]
fn todo() -> Json<Task> { ... }
```

#### Template

rocket 自身包含了模板框架，可以通过 `rocket_contrib` 中的。

example：

```rust
#[get("/")]
fn index() -> Template {
    let context = /* object-like value */;
    Template::render("index", &context)
}
```

1. `render`
1. `Serialize`
1. `template_dir` directory
1. Template 的 engine 的具体使用取决于模板文件的后缀，如 `hbs` -> Handlebars, `.tera` -> Tera
1. 需要将 `Fairing` 注册到 rocket 实例上去。
1. [Template API](https://api.rocket.rs/rocket_contrib/struct.Template.html)
1. [Fairing](https://rocket.rs/guide/fairings/) rocket 提供的结构性中间件

example：

```rust
fn main() {
    rocket::ignite()
      .mount("/", routes![...])
      .attach(Template::fairing());
}
```

### State

有哪些 State：网站的访问次数，任务队列和多个数据库存储状态。

rocket 会为每一种类型管理最多一种状态。基本实现步骤：

1. 在 `rocket` 实例上调用 manage，将你的 application 相关的初始状态传入。
1. 会在每个 request handler 中增加一个 [`State<T>`](https://api.rocket.rs/rocket/struct.State.html) 类型。 

example

```rust
/// 可以通过 manage 方法加入多个状态变量
rocket::ignite()
    .manage(HitCount { count: AtomicUsize::new(0) })
    .manage(Config::from(user_input));

/// 状态可以通过一个 `Request guard` 来获取
#[get("/count")]
fn count(hit_count: State<HitCount>) -> String {
    let current_count = hit_count.count.load(Ordering::Relaxed);
    format!("Number of visits: {}", current_count)
}

/// 可以使用 Within Guard 来获取如下
fn from_request(req: &'a Request<'r>) -> request::Outcome<T, ()> {
    let hit_count_state = req.guard::<State<HitCount>>()?;
    let current_count = hit_count_state.count.load(Ordering::Relaxed);
    // ...
}
```

当 `State<T>` 中的 T 没有对应 manage 时，rocket 不会在运行时才返回 500，而是提供了一个 unmanaged_state lint，在编译时进行检查，并抛出一个异常。目前这个 lint 还不够好，可能需要使用 `#![allow(unmanaged_state)]` 来处理。

#### Database

目前 rocket 中没有数据库管理策略。可以使用 `r2d2` 和 `diesel`，并将其作为 State 的一部分。

```toml
[dependencies]
rocket = "0.3.2"
diesel = { version = "*", features = ["sqlite"] }
diesel_codegen = { version = "*", features = ["sqlite"] }
r2d2-diesel = "*"
r2d2 = "*"
```

```rust
// --- use main.rs ---
extern crate rocket;
#[macro_use] extern crate diesel;
#[macro_use] extern crate diesel_codegen;
extern crate r2d2_diesel;
extern crate r2d2;

use diesel::sqlite::SqliteConnection;
use r2d2_diesel::ConnectionManager;

// An alias to the type for a pool of Diesel SQLite connections.
type Pool = r2d2::Pool<ConnectionManager<SqliteConnection>>;

// The URL to the database, set via the `DATABASE_URL` environment variable.
static DATABASE_URL: &'static str = env!("DATABASE_URL");

/// Initializes a database pool.
fn init_pool() -> Pool {
    let config = r2d2::Config::default();
    let manager = ConnectionManager::<SqliteConnection>::new(DATABASE_URL);
    r2d2::Pool::new(config, manager).expect("db pool")
}

fn main() {
    rocket::ignite()
        .manage(init_pool())
        .launch();
}

// --- define db.rs ---
use std::ops::Deref;
use rocket::http::Status;
use rocket::request::{self, FromRequest};
use rocket::{Request, State, Outcome};

// Connection request guard type: a wrapper around an r2d2 pooled connection.
// 注意此处的实现实际上是包装了一层, 理解实现 FromRequest 实现的机理
pub struct DbConn(pub r2d2::PooledConnection<ConnectionManager<SqliteConnection>>);

/// Attempts to retrieve a single connection from the managed database pool. If
/// no pool is currently managed, fails with an `InternalServerError` status. If
/// no connections are available, fails with a `ServiceUnavailable` status.
impl<'a, 'r> FromRequest<'a, 'r> for DbConn {
    type Error = ();

    fn from_request(request: &'a Request<'r>) -> request::Outcome<DbConn, ()> {
        // 所有的 guard 实际上都在 request.guard 上
        let pool = request.guard::<State<Pool>>()?;
        match pool.get() {
            Ok(conn) => Outcome::Success(DbConn(conn)),
            Err(_) => Outcome::Failure((Status::ServiceUnavailable, ()))
        }
    }
}

// For the convenience of using an &DbConn as an &SqliteConnection.
impl Deref for DbConn {
    type Target = SqliteConnection;

    fn deref(&self) -> &Self::Target {
        &self.0
    }
}

#[get("/tasks")]
fn get_tasks(conn: DbConn) -> QueryResult<Json<Vec<Task>>> {
    all_tasks.order(tasks::id.desc())
        .load::<Task>(&*conn)
        .map(|tasks| Json(tasks))
}
```

思考是使用全局变量比较好还是使用 State 注入的方式比较好？

### [Fairing](https://rocket.rs/guide/fairings/) 整流罩

Fairing 是 rocket 中的一种结构化中间件。使用 Fairing，是的 application 可以 hook 到一个 request 的生命周期中去，记录或者重写 incomming requests 或者 outgoing response 的部分内容。

任意实现了 [`Fairing` trait](https://api.rocket.rs/rocket/fairing/trait.Fairing.html) 的类型都是 Fairing。

+ 如果网站不需要全站登录，那么不要使用 Fairing
+ 尽可能地使用 request guard 而非 Fairing
+ Fairing 可以用于全站访问统计
+ Fairing 可以用于全站的安全设置
+ Fairing 可以用于全站访问延迟统计

+ Fairings cannot terminate or respond to an incoming request directly.
+ Fairings cannot inject arbitrary, non-request data into a request.
+ Fairings can prevent an application from launching.
+ Fairings can inspect and modify the application’s configuration

example 

```rust
// 将 fairing 连接到 rocket
rocket::ignite()
    .attach(req_fairing)
    .attach(res_fairing)
    .launch();
```

+ Fairings are executed in the order in which they are attached

#### Callbacks

```rust
pub trait Fairing: Send + Sync + 'static {
    fn info(&self) -> Info;

    fn on_attach(&self, rocket: Rocket) -> Result<Rocket, Rocket> { ... }
    fn on_launch(&self, rocket: &Rocket) { ... }
    fn on_request(&self, request: &mut Request, data: &Data) { ... }
    fn on_response(&self, request: &Request, response: &mut Response) { ... }
}
```

+ Attach 连接时调用，可以任意地修改 Rocket instance，并且停止 launch 过程。通常用于解析和验证配置的值，遇到错误配置时停止，并将解析的值插入到 managed state 中用于稍后 retieval。
+ Launch Launch callback 主要用于启动相关的服务
+ Request 收到一个 request 时调用，可以修改 request，并且可以查看 body（不能修改），他不能停止或者直接 respond 给 client （这种需求最好使用 request guards 或者 response callback 来实现
+ Response 在即将给 Client 返回 response 时调用，可以修改部分或者全部 response，可以用于重写部分请求的 404 response，
+ rocket 还会使用 info 返回的 Info 结构体来赋予 fairing 的名字，和判断 fairing 注册的位置。
+ 每个 callback 已经有了默认的实现，因而你只需要选择性地自己实现所需的 callback。默认实现什么都不会干。
+ 实现了 Fairing 的类型必须是 `Send + Sync + 'static` 的即可以在线程间传递、线程安全以及只含有静态引用。

example： 记录网站 `Get` 和 `Post` 请求的次数

```rust
struct Counter {
    get: AtomicUsize,
    post: AtomicUsize,
    // 使用了线程安全的变量
}

impl Fairing for Counter {
    // This is a request and response fairing named "GET/POST Counter".
    fn info(&self) -> Info {
        Info {
            name: "GET/POST Counter",
            kind: Kind::Request | Kind::Response
        }
    }

    // Increment the counter for `GET` and `POST` requests.
    fn on_request(&self, request: &mut Request, _: &Data) {
        match request.method() {
            Method::Get => self.get.fetch_add(1, Ordering::Relaxed),
            Method::Post => self.post.fetch_add(1, Ordering::Relaxed),
            _ => return
        }
    }

    fn on_response(&self, request: &Request, response: &mut Response) {
        // Don't change a successful user's response, ever.
        if response.status() != Status::NotFound {
            // 这个 Fairing callback 只处理 NotFound 的请求
            return
        }

        // Rewrite the response to return the current counts.
        // 将路由也之间实现在 Fairing 中
        if request.method() == Method::Get && request.uri().path() == "/counts" {
            // 自己读取数据构建了一个 Response 给 client
            let get_count = self.get.load(Ordering::Relaxed);
            let post_count = self.post.load(Ordering::Relaxed);
            let body = format!("Get: {}\nPost: {}", get_count, post_count);

            response.set_status(Status::Ok);
            response.set_header(ContentType::Plain);
            response.set_sized_body(Cursor::new(body));
        }
    }
}
```

#### [Ad-Hoc](https://api.rocket.rs/rocket/fairing/enum.AdHoc.html) Fairing

简化 Fairing 的实现，可以通过函数或者闭包直接实现一个 Fairing。


## 4 [tokio](https://tokio.rs/)

+ `tokio-proto` 构建 servers 和 clients 的简单接口
+ `tokio-core` 构建自定义的，低层次的异步代码
+ `futures` 提供了 `futures`、`streams`、`sinks` 的概念

### 1 [future](https://tokio.rs/docs/getting-started/futures/)

future 的使用场景：

1. 数据库查询
1. 一个 rpc 的远程调用
1. 超时
1. 一个长时间运行的 CPU 密集任务
1. 从 socket 读取一些字节数据

#### 1 简单的例子

#### 2 combine

+ `then`:
+ `select`: 组合两个相同类型的 futures，并根据完成时间进行 race

> 要进一步补充相关内容

## 5 [error-chain]

更好地利用 rust 的错误处理特征，定义自己的错误，并将其他错误转换过来。参考资料：

+ [starting](http://brson.github.io/2016/11/30/starting-with-error-chain)
+ [doc](https://docs.rs/error-chain/0.10.0/error_chain/)

### 概述

#### why

+ error-chain is easy to configure. Handle errors robustly with minimal effort.
+ Basic error handling requires no maintenance of custom error types nor the From conversions that make ? work.
+ error-chain scales from simple error handling strategies to more rigorous. Return formatted strings for simple errors, only introducing error variants and their strong typing as needed for advanced error recovery.
+ error-chain makes it trivial to correctly manage the cause of the errors generated by your own code. This is the "chaining" in "error-chain".

#### 基本原则

+ 所有的错误都不应该被丢弃，而是 `chain` error。提供了 `chain_err` 方法。
+ 引入的 error 是琐碎的，简单的错误可以通过一个字符串表示。
+ 使用 pattern match 来处理错误。
+ 错误的转换是一致和自动的，`From` 转换行为不应该是特定的。
+ Errors 都实现了 Send
+ Errors 可以携带 backtraces

和类似的库 [error-type](https://github.com/DanielKeep/rust-error-type) 和 [quick-error](http://tailhook.github.io/quick-error/quick_error/index.html) 使用了类似的机理，`error-chain` 也使用了 Cargo 提供的方法。error_chain! 宏定义了完成一个特殊的错误处理策略所需的模板。

特点

1. 没有定义 Error enum，而是定义了 `ErrorKind(fn description, fn display)`，一个透明、boxed、可选的 `std::error::Error + Send + 'static` 对象（其中定义了 `cause`，并在 `error_chain` 中定义了 links，以及一个 Backtrace。
1. 定义了 `ResultExt`，其 `chain_err` 方法可以将 `std::error::Error + Send + 'static` 类型进行 boxed 并保存到 error chain 中。（作为新 concrete error 的 inside)
1. 他提供了自动的 `From` 方法将在 `error_chain!` 中定义的其他错误类型保留 type 信息，将他们灵活地组合起来。

`starting` 中给出了一个模板。

1. 在 Cargo.toml 中添加 `error-chain = "0.10.0"`
1. 实例代码

```rust
mod other_error {
    error_chain! {}
}

error_chain! {
    // The type defined for this error. These are the conventional
    // and recommended names, but they can be arbitrarily chosen.
    //
    // It is also possible to leave this section out entirely, or
    // leave it empty, and these names will be used automatically.
    types {
        Error, ErrorKind, ResultExt, Result;
    }

    // Without the `Result` wrapper:
    //
    // types {
    //     Error, ErrorKind, ResultExt;
    // }

    // Automatic conversions between this error chain and other
    // error chains. In this case, it will e.g. generate an
    // `ErrorKind` variant called `Another` which in turn contains
    // the `other_error::ErrorKind`, with conversions from
    // `other_error::Error`.
    //
    // Optionally, some attributes can be added to a variant.
    //
    // This section can be empty.
    links {
        Another(other_error::Error, other_error::ErrorKind) #[cfg(unix)];
    }

    // Automatic conversions between this error chain and other
    // error types not defined by the `error_chain!`. These will be
    // wrapped in a new error with, in the first case, the
    // `ErrorKind::Fmt` variant. The description and cause will
    // forward to the description and cause of the original error.
    //
    // Optionally, some attributes can be added to a variant.
    //
    // This section can be empty.
    foreign_links {
        Fmt(::std::fmt::Error);
        Io(::std::io::Error) #[cfg(unix)];
    }

    // Define additional `ErrorKind` variants. The syntax here is
    // the same as `quick_error!`, but the `from()` and `cause()`
    // syntax is not supported.
    errors {
        InvalidToolchainName(t: String) {
            description("invalid toolchain name")
            display("invalid toolchain name: '{}'", t)
        }
    }
}
```

## 6 protobuf

```bash
cargo install protobuf
```

## 7 hyper

+ [Guide Page](https://hyper.rs/guides/)

`Body` 实现了 `Stream` trait，当收到数据时返回一系列的 `Chunk`， `Chunk` 只是一些 bytes 的表示。

```rust
#[derive(Debug, Clone)]
pub struct PostData {
    pub url: String,
    pub data: Vec<u8>,
    pub headers: Option<Headers>,
}

impl PostData {
    pub fn new(url: &str, data: Vec<u8>, headers: Option<Headers>) -> Self {
        PostData {
            url: url.to_owned(),
            data: data,
            headers: headers,
        }
    }
}

pub fn post_req(post_data: &PostData) -> Result<Request> {
    let url = post_data.url.parse::<hyper::Uri>()?;
    let mut req = Request::new(Post, url);
    {
        let headers = req.headers_mut();

        // 从全局配置中获得 token
        let access_token = CONFIG
            .read_lock()
            .access_token
            .clone()
            .unwrap_or("".to_owned());
        let mut cookie = Cookie::new();
        cookie.append("session", access_token);

        // 设置 http 头文件
        headers.set(cookie);
        headers.set(ContentType(Mime::from_str("application/json").unwrap()));

        // post_data 增加了 header 内容
        match post_data.headers {
            Some(ref passed_headers) => {
                headers.extend(passed_headers.iter());
            }
            None => {}
        }
    }
    req.set_body(post_data.data.clone());
    Ok(req)
}

pub fn get_client(handle: &Handle) -> hyper::Client<hyper_tls::HttpsConnector<HttpConnector>> {
    let client = hyper::Client::configure()
        .connector((hyper_tls::HttpsConnector::new(4, handle)).unwrap())
        .build(handle);

    client
}

pub fn fetch_async(req: Request,
                    client: &hyper::Client<hyper_tls::HttpsConnector<HttpConnector>>)
                    -> impl Future<Item = CallbackData, Error = CallbackData> {
    let timer = Timer::default();
    let timeout = timer
        .sleep(Duration::from_millis(TIMEOUT))
        .or_else(|e| {
                      warn!("timeout error");
                      Err(CallbackData::new(CallbackCode::TimerError(e), None, vec![], None))
                  })
        .and_then(|_| {
                      warn!("request timeout");
                      Err(CallbackData::new(CallbackCode::Timeout,
                                            None,
                                            "timeout".to_string().into_bytes(),
                                            None))
                  });
    trace!("start process uri: {}", req.uri());

    let now = Instant::now();
    let work = client
        .request(req)
        .and_then(|res| {
            let status = res.status();
            let headers = res.headers().clone();
            trace!("Response: {}", status);
            res.body()
                .fold((status, headers, Vec::new()),
                      |(status, headers, mut acc), chunk| {
                          acc.extend_from_slice(chunk.as_ref());
                          Ok::<_, hyper::Error>((status, headers, acc))
                      })
        })
        .and_then(move |(status, headers, body)| {
            let pb_status = match Fetch::get_pb_status(status, &body) {
                Ok(pb_status) => pb_status,
                Err(err) => {
                    warn!("get pb status failed: err= {:?}", err);
                    None
                }
            };
            info!("fetch cost: {:?}", now.elapsed());

            Ok(CallbackData::new(CallbackCode::Normal(status), Some(headers), body, pb_status))
        })
        .or_else(|e| {
                      trace!("HyperError: {:?}", e);
                      Err(CallbackData::new(CallbackCode::HyperError(e), None, vec![], None))
                  });

    let work = work.select(timeout)
        .and_then(|(callback_data, _)| Ok(callback_data))
        .or_else(|(e, _)| {
                      info!("fetch_async_error: {:?}", e);
                      Err(e)
                  });

      work
}
```

> 要进一步补充相关内容

## 8 log

+ [log facade document](https://doc.rust-lang.org/log/log/index.html)
+ [env_logger](https://docs.rs/env_logger/*/env_logger/)
+ [log4r]()

## 9 lazy_static 和配置文件的实现

```rust
#[macro_use]
extern crate lazy_static;

use std::sync::{RwLock, RwLockReadGuard, RwLockWriteGuard};

#[derive(Default, Debug)]
pub struct Config {
    pub storage_path: String,
    pub access_token: Option<String>,
    pub device_id: Option<String>,
    pub user_id: Option<i64>,
    pub inited: bool,
    pub net_type: Option<i32>,
}

pub trait RW<T> {
    fn read_lock(&self) -> RwLockReadGuard<T>;
    fn write_lock(&self) -> RwLockWriteGuard<T>;
}

impl<T> RW<T> for RwLock<T> {
    fn read_lock(&self) -> RwLockReadGuard<T> {
        self.read()
            .unwrap_or_else(|poisoned| poisoned.into_inner())
    }
    fn write_lock(&self) -> RwLockWriteGuard<T> {
        self.write()
            .unwrap_or_else(|poisoned| poisoned.into_inner())
    }
}

lazy_static! {
    pub static ref CONFIG: RwLock<Config> = {
        let m:Config = Default::default();
        RwLock::new(m)
    };
}
```

`RW` trait 增加了 mutex poisoning 时的处理。

使用

```rust
use xxx::{CONFIG, RW};

let access_token = CONFIG
            .read_lock()
            .access_token
            .clone()
            .unwrap_or("".to_owned());  // access 是一个Option 对象，因而需要进行如此的处理
```
