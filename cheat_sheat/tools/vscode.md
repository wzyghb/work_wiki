# vscode 备忘录

## 安装和配置

### 常规

+ mac 加入到命令行下： [说明](https://code.visualstudio.com/docs/setup/mac)

## vscode 快捷键说明。

[vscode key map](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf)

+ 会搜索
+ 会打开文件
+ 会切换来回资源管理器
+ 会分割窗口并切换
+ 会关闭窗口
+ 会打开命令行
+ 会浏览代码，前进后退等
+ 会 debug python
+ 会 debug rust

### 基本命令

| 命令 | 说明 |
| :--- | :--- |
| `Alt` `Up` / `Alt` `Down` | 移动这一行代码 |
| `Shift` `Alt` `Up` / `Shift` `Alt` `Down` | 向上向下复制一行 |
| `ctrl` `tab` | 切换标签 |
| `cmd` `n` | 打开新标签 |
| `cmd` `w` | 关闭标签 |
| `cmd` `\` | 垂直分割 |
| `ctrl` `g` `num` | 跳转到指定的行 |
| `cmd` `p` | 打开文件 |
| `cmd` `shift` `e` | 打开资源管理器 |
| `cmd` `shift` `f` | 打开搜索 |
| `ctrl` `shift` `g` | 打开 git |
| `cmd` `shift` `v` | markdown preview |
| `cmd` `b` | 显示 / 不显示侧边栏 |
| `cmd` `shift` `d` | ~~打开 debug~~ |
| `cmd` `| 打开自带的 terminal |
| `F12` | 跳转到定义处 |
| `ctrl` `_` | 位置后退 |
| `ctrl` `shift` `_` | 位置前进 |
| `ctrl` `alt` `n` | 执行代码，用于 go 的 main 函数 |
| `cmd` `k` + `cmd` `方向键` | 将 focus 移动到指定的相关区域 |

### CMD + p 命令模式

+ 直接输入文件名打开文件
+ `:` 跳转到指定的行
+ `@` 调转到指定的 symbol

## 常用插件使用总结

### Code Runner

+ `ALT+CTRL+N` 运行这一段代码

### Dash

+ `ctrl` `h` : It will search for current specific documentation depends on language.
+ `ctrl` `alt` `h` : It will search for all documentation.

### git history

在命令行輸入框中輸入history，点击 git log。

| 信息 | 指令 |
| 查看项目的 commit 历史 | git.viewHistory |
| 查看文件的历史信息 | git.viewFileHistory |
| 查看某几行的历史 | git.viewLineHistory |

### rusty code

+ 在插件中安装 rusty code 插件
+ `cargo install racer` [racer repo](https://github.com/racer-rust/racer)
+ `cargo install rustfmt-nightly` [rustfmt repo](https://github.com/rust-lang-nursery/rustfmt)
+ 安装源码环境
    ```bash
    git clone https://github.com/rust-lang/rust.git
    cd rust
    ./x.py build && sudo ./x.py install
    ```
+ 为了 使 racer 正常运行需要安装 rust 源代码： `rustup component add rust-src`

### python

+ 安装 python 插件
+ 安装 `ctags` 执行 `brew install ctags`
+ [Select workplace interpret](https://github.com/DonJayamanne/pythonVSCode/wiki/Miscellaneous#select-an-interpreter)
+ [python 插件文档](https://github.com/DonJayamanne/pythonVSCode/wiki)
+ 在 .vscode 下的 settings.json 中设定指定的解释器
    `"python.pythonPath": "/Users/ly/Code/venv/bin/python"`

### [Go](https://github.com/Microsoft/vscode-go/wiki/Debugging-Go-code-using-VS-Code)

+ 首先在 vscode 中运行 `Go: Install/Update Tools` 安装 [delve](https://github.com/derekparker/delve)
+ 按 `F5` 打开 `launch.json` 配置 `mode`, `program`, `env`
+ [`govendor`](https://github.com/kardianos/govendor)
  + `init`
  + `fetch`
  + `fmt`
  + `install`
  + `test`
  + `list`
  + `add`
+ `go get`

### docker

### vscode-database
