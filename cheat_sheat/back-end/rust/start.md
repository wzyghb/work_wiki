# for start

## scope

+ rust 相关的工具：包管理、编译、运行、代码检查、ci、测试、rust 版本管理工具
+ 基础库总结
+ 主要使用的外部库总结
+ rust 编程语言的基本概念

## tools

+ [`cargo`](http://doc.crates.io/manifest.html)
+ `cargo-check`
+ `multirust`
+ `cargo test` `#[test]`
  + `assert!(...)`
  + `assert_eq!(...)`
  + `panic!(...)`

## concept

+ ownership
+ borrowing
+ lifetimes

## cargo

### 目录结构

```yml
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
+ `tests` 集成测试，并非单元测试
+ `example` 是例子 通过 `cargo test` 进行构建，通过 `cargo run --example foo` 运行
+ `benches` 是性能测试目录

### cargo 使用

+ 在构建时加入新的特征 `cargo build --features using-html9`
+ 在构建时引入 clippy `cargo build --all --features "clippy"`
+ 在 cargo.toml 中实现新特征使用

```bash
[packege]
name = "myfacebumblr"

[features]
default = ["web-vortal"]

web-vortal = []

using-html9 = ["h9rbs-js/commodore64"]

[dependencies]
h9rbs-js = { optinal = "true" }
```

+ 使用构建脚本

```bash
[package]
build = "build.rs"
```

## rustup 实现 rust 版本管理

rust 存在三个版本，stable、beta 和 nightly 版本，rustup 就是用于管理这三个版本的工具。

+ 安装

```bash
curl https://sh.rustup.rs -sSf | sh
```

+ 更新

```bash
rustup update
rustup update nightly
```

可以通过环境变量指定下载的镜像：

```bash
export RUSTUP_DIST_ROOT=https://mirrors.ustc.edu.cn/rust-static
```

+ 指定版本

```bash
rustup default nightly  // 设定系统的默认版本
rustup override beta    // 设置某个项目使用的 rust 的版本
```

+ 跨平台编译
  + 添加工具链 `rustup target add arm-linux-androidabi`
  + 列出工具链 `rustup target list`
+ 实现： 底层调用 rust 版本的 multirust，安装的时候会下载 rustup、rustc、cargo、rustdoc、multirust 到 `$HOME/.cargo/bin`，后版本相关的工具会放在 `$HOME/.multirust` 目录下，设置版本和工具后，rust 和 cargo 命令均会代理到 `$HOME/.multirust` 目录下真正的工具链，与 ruby 下的 rbenv 和 pyenv 类似。

## 读写锁

```rust
use std::sync::{RwLock, RwLockReadGuard, RwLockWriteGuard};
```

## 常见的宏总结

+ `#[test]` 标识一个函数式用于测试的
+ `#![test]` 标识周围的模块

```rust
#[test]
fn midterm1() {
  // ...
}

fn midterm2() {
  #![test]
  // ...
}
```

+ `#![no_std]`
+ `#[derive(Debug)]`
+ `#[inline(always)]` 编译器操作指令，内联
+ `#[allow(missing_docs)]` 允许不存在常规的 certain lints
+ `#![crate_type = "lib"]` 提供 crate 的 metadata
+ `#![feature(box_syntax)]` 允许不稳定的新语法
+ `#[cfg(target_os = "linux")]` 定义条件编译

## rust 中的宏

### C 的宏的局限

+ 无法识别 variables, types, operators, numbers 等真实的意义。
+ 无法实现递归
+ `#include <stdio.h>` 导致文件变大，编译变慢

### rust 中的语法扩展

+ [attributes](https://doc.rust-lang.org/book/attributes.html) [attributes list](https://doc.rust-lang.org/reference/attributes.html)
+ macro `foo! args`、`foo!(...)`、`foo![...]`、`foo!{...}`
+ macro_rules `foo! arg arg` `macro_rules! name { definition }`

## Problems

+ [format need a string literal](https://stackoverflow.com/questions/27734708/println-error-format-argument-must-be-a-string-literal)

## next to learn

+ rocket
+ diesel
+ tokio
+ futures
+ [data structure](https://github.com/EbTech/rust-algorithms)
+ cross compile
+ [nomicon book](https://doc.rust-lang.org/nomicon/)
+ [macro book](https://danielkeep.github.io/tlborm/book/)
+ [reqwest 代码](https://github.com/seanmonstar/reqwest)
+ [r2d2 代码](https://github.com/sfackler/r2d2)
+ [rocket 代码](https://github.com/SergioBenitez/Rocket)
