# Flask 源代码阅读

flask 是项目中主要使用的 web framework。因而在工作之余阅读了 flask 的源代码，flask 和 werkzeug 都是优秀的 python 的优秀源代码。

## flask 源码概述

flask 基于 werkzeug 实现，项目中涉及到的功能和对应的源代码文件如下表所示:

| 源代码文件名 | 主要相关功能 | 阅读状态 |
| :--- | :--- | :--- |
| `app.py` | 主模块，实现 flask 的主要功能，详细见下文描述 | doing |
| `sessions.py` | 一个 flask session 的简单实现 | done |
| `blueprints.py` | 蓝图的实现 | doing |
| `wrappers.py` | werkzeug request 和 response 的封装 | done |
| `views.py` | views 的另一种形式 | done |
| `logging.py` | 日志模块 | doing |
| `ctx.py` | 上下文对象，包括 RequestContext 和 AppContext | done |
| `config.py` | 配置策略定义 | done |
| `globals.py` | 全局变量 | done |
| `helpers.py` | 辅助函数 | done |
| `exthook.py` | 扩展支持 | before |
| `json.py` | json 相关 | before |
| `signal.py` | 信号 | before |
| `templating.py` | 模板 | before | 
| `cli.py` | 命令行 | before |
| `debughelpers.py` | 提升开发测试的体验 | before |
| `testing.py` | 测试 | before |

## app 模块

+ `Flask`

### 配置的类：

+ `request_class`
+ `response_class`
+ `jinja_environment`
+ `app_ctx_global_class`
+ `request_globals_class`
+ `config_class`
+ `url_rule_class`
+ `test_client_class`
+ `session_interface`

### 配置属性

#### class 配置

+ `debug`
+ `testing`
+ `secret_key`
+ `session_cookie_name`
+ `permanent_session_lifetime`
+ `send_file_max_age_default`
+ `use_x_sendfile`
+ `logger_name`
+ `json_encoder`
+ `json_decoder`
+ `jinja_options`

#### object 配置

+ `static_url_path`
+ `static_folder`
+ `instance_path`
+ `config`
+ `logger_name`
+ `view_functions`
+ `_error_handlers`
+ `error_handler_spec`
+ `url_build_error_handlers`
+ `before_request_funcs`
+ `before_first_request_funcs`
+ `after_request_funcs`
+ `teardown_request_funcs`
+ `teardown_appcontext_funcs`
+ `url_value_preprocessors`
+ `url_default_functions`
+ `template_context_processors`
+ `shell_context_processors`
+ `blueprints`
+ `_blueprint_order`
+ `extensions`
+ `url_map`
+ `_get_first_request`
+ `_before_request_lock`
+ `cli`

## config

+ `ConfigAttribute`
+ `Config`
  + `from_envvar`
  + `from_pyfile`
  + `from_object`
  + `from_json`
  + `from_mapping`
  + `get_namespace`

## views

+ `View`
  + `methods`
  + `decorators`
  + `dispatch_request`
  + `as_view`
+ `MethodViewType` 构建 `MethodViewType` 的元类，根据 MethodView 中定义的方法，构建 methods 属性，元类的典型应用。
+ `MethodView`  使用 get、post 等方法分配请求

## sessions

+ `SessionMixin`
+ `TaggedJSONSerializer`
+ `SecureCookieSession`
+ `NullSession`
+ `SessionInterface`
  + `make_null_session`
  + `get_cookie_domain`
  + `get_cookie_path`
  + `get_cookie_httponly`
  + `get_cookie_secure`
  + `get_expiration_time`
  + `should_set_cookie`
  + `open_session`
  + `save_session`
+ `SecureCookieSessionInterface`

## wrappers

主要是 `werkzeug.wrappers.(Request\Response)` 的封装。

+ `Request`
  + `url_rule`
  + `view_args`
  + `routing_exception`
  + `max_content_length`
  + `endpoint`
  + `module`
  + `blueprint`
  + `json`
  + `is_json`
  + `get_json`
+ `Response`

## globals

+ `_request_ctx_stack`
+ `_app_ctx_stack`
+ `current_app`
+ `request`
+ `session`
+ `g`

## helpers

+ `stream_with_context` 装饰器，避免内存泄露
+ `make_response`  构建 response
+ `url_for`  查找 endpoint 对应的 url
+ `get_template_attribute`
+ `flash`
+ `get_flashed_messages`
+ `send_file`  发送文件
+ `safe_join`  安全地将不受信任，由前端传入的文件拼接到文件路径中
+ `send_from_directory`  使用 sendfile 从指定 directory 发送一个文件
+ `get_root_path`  返回模块所在的根目录
+ `find_package`
+ `locked_cached_property`
+ `_PackageBoundObject`  Flask 的父类，主要处理资源文件
  + `has_static_folder`
  + `jinja_loader`
  + `get_send_file_max_age`
  + `send_static_file`
  + `open_resource`
+ `total_seconds`

## ctx

+ `after_this_request`
+ `copy_current_request_context`
+ `has_request_context`  `_request_ctx_stack` 是否为空
+ `has_app_context`  `_app_ctx_stack` 是否为空
+ `AppContext`  管理 `globals` 中的 `_app_ctx_stack`
  + `push`
  + `pop`
+ `RequestContext` 请求上下文管理，最好使用 `test_request_context` 和 `request_context`
  + `request`  封装的 `app.request_class` 实例
  + `url_adapter`  url 适配器
  + `flashes`  展现
  + `session`  session
  + `g`  `_app_ctx_stack.top.g` 的封装
  + `copy`  伪副本，主要用于 greenlet 之间进行共享，不能在多线程下进行共享
  + `match_request`  请求匹配
  + `push`  将请求上下文绑定到当前的上下文中
    + 当处于 debug 模式或者设置了保存上下文时，这时 request context 会保存在栈里，以用于错误分析
    + 流程
      + `_request_ctx_stack` 非空，且设置了 preserved，则进行清除
      + `_app_ctx_stack` 为空，则进行入栈
      + 使用 `sys.exc_clear` 清除系统级别保存的异常
      + 将自己加入到 `_request_ctx_stack` 中
      + 调用 `app.open_session` 打开 session，或者设定一个 `NullSession`
      + 不会调用 `before_first_request_funcs` 和 `before_request_funcs`
  + `pop`  解除在上下文中的绑定，同时触发 `teardown_request`
    + `_implicit_app_ctx_stack` 出栈
    + 设置 `prezerved` 和 `_preserved_exc` 等字段
    + 调用 `do_teardown_request`
    + 调用 `sys.exc_clear` 清除异常信息
    + 调用可选的 `request.close` 方法
    + `_request_ctx_stack` 中出栈
    + `app_ctx` 出栈
  + `auto_pop`
  + 难点 `_implicit_app_ctx_stack` 的作用。

## Problems

+ [为何 flask 有 context 的设计](https://stackoverflow.com/questions/20036520/what-is-the-purpose-of-flasks-context-stacks)
