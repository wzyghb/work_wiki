
+ [使用的配置](https://github.com/gpakosz/.tmux)
+ [中文文档](http://mindonmind.github.io/notes/linux/tmux.html)

## tmux 基本概念

+ Session: 一组窗口的集合，通常用于概括同一个任务。
+ Window: 单个可见窗口，类似于 item2 中的 Tab
+ Pane: 每一个分割

## tmux 基本操作

tmux 的前置操作是： CTRL+b, 下文以 prefix 代替

### Session 相关操作

| 操作 | 快捷键 |
| ---: | ---: |
| 查看/切换 session | prefix s |
| 离开 session | prefix d |
| 重命名当前 session | prefix $ |
| 前 or 后一个会话 | prefix ( or ) |
| 选择要离开的会话 | prefix D |
| 进入命令行模式 | prefix : |


### Windows 相关的操作

| 操作 | 快捷键 |
| ---: | ---: |
| 新建窗口 | prefix c |
| 采用下一个内置布局 | prefix space |
| 关闭一个窗口 | prefix & |
| 使用窗口号切换 | prefix 窗口号 |
| 切换到最近使用的窗口 | prefix l |
| 以菜单方式显示和选择窗口 | prefix w |
| 修改窗口的名称 | prefix , |
| 搜索并切换窗口到结果 | prefix f |
| 修改窗口编号 | prefix . |
| ~~切换到下一个窗口~~ | prefix n |
| ~~切换到上一个窗口~~ | prefix p |

### Pane 相关操作

| 操作 | 快捷键 |
| ---: | ---: |
| 切换到下一个窗格 | prefix o |
| 查看所有窗格的编号 | prefix q |
| 垂直拆分出一个新的窗格 | prefix " |
| 水平拆分出一个新的窗格 | prefix % |
| 暂时将一个窗体放到最大 | prefix z |
| 关闭面板 | prefix x |
| 切换到上下左右的分割面板 | prefix + 方向键 |
| 将当前面板变为新窗口 | prefix ! |
| 调换面板的位置 | prefix ctrl+o |
| 调整分割窗口的大小 | prefix ctrl + 方向键 |
| 选择指定面板 | prefix 数字 |
| 上 or 下交换面板 | prefix { or } |



### 其他操作

| 操作 | 快捷键 |
| ---: | ---: |
| 显示快捷键帮助 | prefix ? |
| 删除 session | tmux kill-session -t session-name |
| 重新连接session | tmux attach -t session-name |
| 显示保存的会话 | tmux ls |

### gpakosz 模式引入的特性

[gpakosz](https://github.com/gpakosz/.tmux)

| 操作 | 快捷键 |
| ---: | ---: |
| 鼠标模式 | prefix + m |
| 
