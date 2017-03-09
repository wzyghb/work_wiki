
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
