
# tools

+ [`cargo`](http://doc.crates.io/manifest.html)
+ `cargo-check`
+ `multirust`
+ `cargo test` `#[test]`
  - `assert!(...)`
  - `assert_eq!(...)`
  - `panic!(...)`

# concept

+ ownership: 
+ borrowing
+ lifetimes

# reference

+ [rustwebapp](https://github.com/superlogical/rustwebapp)
+ [web docker](https://github.com/clementmiao/website-rocket)
+ [thanks](https://github.com/rust-lang-nursery/thanks)
+ [rustironreact](https://github.com/cmsd2/rust-iron-react-webpack)

# iron

| iron |  | http://ironframework.io/doc/iron/ |
| router | https://github.com/iron/router | http://ironframework.io/doc/router/ |
+ [mount]()
+ [Chain]()
+ [Key]()
+ [handlebars_iron]()  模板文件
+ [persistent](http://ironframework.io/doc/persistent/) Middleware 在 request 之间共享数据。

# Project layout _garde by cargo_

```
.
├── Cargo.lock
├── Cargo.toml
├── benches
│   └── large-input.rs
├── examples
│   └── simple.rs
├── src
│   ├── bin
│   │   └── another_executable.rs
│   ├── lib.rs
│   └── main.rs
└── tests
    └── some-integration-tests.rs
```

+ `Cargo.toml` 和 `Cargo.lock` 存储在项目的 `root`。
+ 源代码存储在 `src` 目录下
+ 默认的库是 `src/lib.rs`
+ 默认的可执行文件是 `src/main.rs`
+ 其他的可执行文件可以放在 `src/bin/*.rs`
+ `tests` 目录下有测试文件集成
+ `example` 是例子
+ `benches` 是性能测试目录

rust 存在三个版本，stable、beta 和 nightly 版本，rustup 就是用于管理这三个版本的工具。

+ 安装
```
curl https://sh.rustup.rs -sSf | sh
```

+ 更新
```
rustup update
rustup update nightly
```

可以通过环境变量指定下载的镜像：

```
export RUSTUP_DIST_ROOT=https://mirrors.ustc.edu.cn/rust-static
```

+ 指定版本

```
rustup default nightly  // 设定系统的默认版本
rustup override beta    // 设置某个项目使用的 rust 的版本
```

+ 跨平台编译
  - 添加工具链 `rustup target add arm-linux-androidabi`
  - 列出工具链 `rustup target list`

+ 实现： 底层调用 rust 版本的 multirust，安装的时候会下载 rustup、rustc、cargo、rustdoc、multirust 到 
`$HOME/.cargo/bin`，然后版本相关的工具会放在 `$HOME/.multirust` 目录下，设置版本和工具后，rust 和 cargo 命令
均会代理到 `$HOME/.multirust` 目录下真正的工具链，与 ruby 下的 rbenv 和 pyenv 类似。

