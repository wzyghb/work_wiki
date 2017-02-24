
flask 是项目中主要使用的 web framework。因而在工作之余阅读了 flask 的源代码，flask 和 werkzeug 都是优秀的 python 的优秀源代码。

## flask 源码概述

flask 基于 werkzeug 实现，项目中涉及到的功能和对应的源代码文件如下表所示:

| 源代码文件名 | 主要相关功能 | 阅读状态 |
| :--- | :--- | :--- |
| `app.py` | 主模块，实现 flask 的主要功能，详细见下文描述 | doing |
| `sessions.py` | 一个 flask session 的简单实现 | doing |
| `blueprints.py` | 蓝图的实现 | doing |
| `wrappers.py` | werkzeug request 和 response 的封装 | done |
| `views.py` | views 的另一种形式 | done |
| `logging.py` | 日志模块 |
| `ctx.py` | 上下文对象，包括 RequestContext 和 AppContext | doing |
| `config.py` | 配置策略定义 | done |
|

## app 模块

