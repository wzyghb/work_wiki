werkzeug 基础总结
----

在头条的开发中，基础框架使用 flask 框架，而 flask 框架底层使用 werkzeug 实现。（jinja2 很少使用。项目中大部分通过 restful api 向前端返回数据。
因而总结了下 werkzeug 的基础知识。

另外有：
+ [werkzeug 源码阅读](https://github.com/LianYun/werkzeug)
+ [werkzeug 中文文档 0.9.4](http://werkzeug-docs-cn.readthedocs.io/zh_CN/latest/index.html)
+ [werkzeug English 0.11](http://werkzeug.pocoo.org/docs/0.11/)

## 1. WSGI 基础

要理解 Werkzeug 首先要理解:
+ [WSGI APP](https://www.python.org/dev/peps/pep-0333/)
+ [知乎上的解释](https://www.zhihu.com/question/19998865)

首先 WSGI 组件可以分为 Server、Middleware 和 Application 三种。 其中 Middleware 是设计模式中的 Decorator。
下面就是 Application 的基本形式：

```python
def application(environ: Dict[String, Any], start_response: (String, List] -> Any)) -> Iterable[String]:   
    """
    接受 environ 和 start_response 两个参数。
    environ: 数据。
    start_response: 上层处理方法。
    这两个部分由 Server 注入给 Application，称之为依赖注入。
    实际上，这在设计模式称之为控制反转 IoC
    """
    start_response('200 OK', [('Content-Type', 'text/plain')])
    return ['Hello World!']
```
Application 就是一个 Python 的可调用对象。Werkzeug 就是这种底层的 WSGI 的封装。比如说下面的例子中对请求和响应进行封装：

```python
from werkzeug.wrappers import Request, Response

def application(environ, start_response):
    request = Request(environ)
    text = 'Hello %s!' % request.args.get('name', 'World')
    response = Response(text, mimetype='text/plain')
    return response(environ, start_response)
```

从类型的角度来讲，Application 可以定义为一个具有下面形式的类型：

```python
type Application = (Dict[String, Any], (String, List) -> Any)) -> Iterable[String]
```

而 Middleware 本质上是一个装饰器 Decorator，和 Application 类似它也是一个 Callable 对象，其签名可以具有如下形式：

```python
def __call__(app: Application): transformedApp: Application
```

Server 更像是一个 Adapter，其基本职责是：
1. 从 os.environ 或者 sys.stdin 中获得 Request 数据，自定义 `start_response` 和 write 函数，
在其中使用 sys.stdout 进行响应，并且将 environ 和 `start_response` 传递给 Application 进行调用，然后遍历 Application 返回
的 Iterable，使用 write 函数把结果写入到 sys.stdin （完成和更上层，一般是 nginx 的通讯）。


## 2. 基本组成

### 1. 请求/响应对象

request 和 response 对象封装了 WSGI 环境或者从 WSGI 应用返回的值，婴儿是另一种 WSGI application。
WSGI 函数有两个参数， environ 和 start_response, Request 类包装了 environ，使得我们可以更加方便地访问请求变量，如 data、请求头等。
而 Response 则是一个标准的 WSGI 应用。

使用的例子：
```python
from werkzeug.wrappers import Request, Response

# 1
application = Response('Hello World!')

# 2
def application(environ, start_response):
    request = Request(environ)
    response = Response("Hello %s!" % request.args.get('name', 'World!'))
    return response(environ, start_response)

# 3
@Request.application
def application(request):
    return Response("Hello %s!" % request.args.get('name', 'World!'))
```

#### 设计准则
+ request 对象：
    1. request 对象是不可变的。默认是不支持修改的。
    2. request 对象可以在同一个线程中共享，但是自身并不支持线程安全。
    3. 不能对 request 对象进行 pickle。
+ response 对象：
    1. response 对象是可变的。
    2. 对其调用 freeze() 方法后可以进行 pickle 和 copy。
    3. 可以使用一个 response 对象用于多个 WSGI 的响应。
    4. 可以使用 copy.deepcopy 创建一个副本。

#### 包的组成

基本组成：
+ werkzeug.wrappers.BaseRequest(environ, populate_request=True, shallow=False)
+ werkzeug.wrappers.BaseResponse(response=None, status=None, headers=None, mimetype=None, content_type=None)

werkzeug 也提供了一些 Mixin 来丰富处理逻辑：
+ Request(BaseRequest, AcceptMixin, ETagRequestMixin, UserAgentMixin, AuthorizationMixin, CommonRequestDescriptorsMixin)
+ Response(BaseResponse, ETagResponseMixin, ResponseStreamMixin, CommonResponseDescriptorsMixin, WWWAuthenticateMixin)

### 2. URL 路由

### 3. WSGI 辅助函数

日期的解析
头部的解析
Cookies 的解析

### 4. HTTP 公共包

### 5. Data Structure

#### 1 General Purpose

+ werkzeug.datastructures.TypeConversionDict
+ werkzeug.datastructures.ImmutableTypeConversionDict
+ werkzeug.datastructures.MultiDict
+ werkzeug.datastructures.ImmutableMultiDict
+ werkzeug.datastructures.ImmutableOrderedMultiDict
+ werkzeug.datastructures.CombinedMultiDict
+ werkzeug.datastructures.ImmutableDict
+ werkzeug.datastructures.ImmutableList
+ werkzeug.datastructures.FileMultiDict

#### 2 HTTP 相关

+ werkzeug.datastructures.Headers
+ werkzeug.datastructures.EnvironHeaders
+ werkzeug.datastructures.HeaderSet
+ werkzeug.datastructures.Accept
+ werkzeug.datastructures.MIMEAccept
+ werkzeug.datastructures.CharsetAccept
+ werkzeug.datastructures.LanguageAccept
+ werkzeug.datastructures.RequestCacheControl
+ werkzeug.datastructures.ResponseCacheControl
+ werkzeug.datastructures.ETags
+ werkzeug.datastructures.Authorization
+ werkzeug.datastructures.WWWAuthenticate
+ werkzeug.datastructures.IfRange
+ werkzeug.datastructures.Range
+ werkzeug.datastructures.ContentRange

#### 3 其他

werkzeug.datastructures.FileStorage

### 6. 公共包

#### 1 HTML Helpers

+ werkzeug.utils.HTMLBuilder
+ werkzeug.utils.escape
+ werkzeug.utils.unescape

#### 2 一般的 Helpers

+ werkzeug.utils.cached_property
+ werkzeug.utils.environ_property
+ werkzeug.utils.header_property
+ werkzeug.utils.parse_cookie
+ werkzeug.utils.dump_cookie
+ werkzeug.utils.redirect
+ werkzeug.utils.append_slash_redirect
+ werkzeug.utils.import_string
+ werkzeug.utils.find_modules
+ werkzeug.utils.validate_arguments
+ werkzeug.utils.secure_filename
+ werkzeug.utils.bind_arguments

#### 3 URL Helpers

+ werkzeug.urls.Href
+ werkzeug.urls.url_decode
+ werkzeug.urls.url_decode_stream
+ werkzeug.urls.url_encode
+ werkzeug.urls.url_encode_stream
+ werkzeug.urls.url_quote
+ werkzeug.urls.url_quote_plus
+ werkzeug.urls.url_unquote
+ 

#### 4 UserAgent Parsing

werkzeug.useragents.UserAgent

#### 5 安全 Helpers

+ werkzeug.security.generate_password_hash
+ werkzeug.security.check_password_hash
+ werkzeug.security.safe_str_cmp
+ werkzeug.security.safe_join
+ werkzeug.security.pbkdf2_hex
+ werkzeug.security.pbkdf2_bin

### 7 上下文局部 Context local

示例代码：

```python
from werkzeug.local import Local, LocalManager

local = Local()
local_manager = LocalManager([local])

def application(environ, start_response):
    local.request = request = Request(environ)
    ...

application = local_manager.make_middleware(application)
```

+ werkzeug.local.LocalManager
+ werkzeug.local.LocalStack
+ werkzeug.local.LocalProxy

### 8 中间件 Middleware

+ werkzeug.wsgi.SharedDataMiddleware(app, exports, disallow=None, cache=True, cache_timeout=43200, fallback_mimetype='text/plain')
主要用于挂载静态文件。

+ werkzeug.wsgi.DispatcherMiddleware(app, mounts=None)
将多个 wsgi app 组合起来。

### 9 HTTP Exception
+ 400 - 431
+ 500-503

所有异常的基类：

```python
werkzeug.exceptions.HTTPException(description=None, response=None)
    def __call__(environ, start_response):
        pass
    def get_response(environ=None):
        pass
```

## 3. 一个简单的教程

### 1. 创建目录

```
/shortly
    /static
    /templates
```

### 2 一个基本的应用程序

```python
import os
import redis
import urlparse
from werkzeug.wrappers import Request, Response
from werkzeug.routing import Map, Rule
from werkzeug.exceptions import HTTPException, NotFound
from werkzeug.wsgi import SharedDataMiddleware
from werkzeug.utils import redirect
from jinja2 import Environment, FileSystemLoader


class Shortly(object):

    def __init__(self, config):
        self.redis = redis.Redis(config['redis_host'], config['redis_port'])

    def dispatch_request(self, request):
        return Response('Hello World!')

    def wsgi_app(self, environ, start_response):
        request = Request(environ)
        response = self.dispatch_request(request)
        return response(environ, start_response)

    def __call__(self, environ, start_response):
        return self. wsgi_app(environ, start_response)


def create_app(redis_host='localhost', redis_port=6379, with_static=True):
    app = Shortly({
        'redis_host':       redis_host,
        'redis_port':       redis_port
    })
    if with_static:
        app.wsgi_app = SharedDataMiddleware(app.wsgi_app, {
            '/static':  os.path.join(os.path.dirname(__file__), 'static')
        })
    return app


if __name__ == '__main__':
    from werkzeug.serving import run_simple
    app = create_app()
    run_simple('127.0.0.1', 5000, app, use_debugger=True, use_reloader=True)
```

### 3 环境

实现模板的渲染和数据库的连接。

```python
def __init__(self, config):
    self.redis = redis.Redis(config['redis_host'], config['redis_port'])
    template_path = os.path.join(os.path.dirname(__file__), 'templates')
    self.jinja_env = Environment(loader=FileSystemLoader(template_path),
                                 autoescape=True)

def render_template(self, template_name, **context):
    t = self.jinja_env.get_template(template_name)
    return Response(t.render(context), mimetype='text/html')
```

### 4 路由

```python
self.url_map = Map([
    Rule('/', endpoint='new_url'),
    Rule('/<short_id>', endpoint='follow_short_link'),
    Rule('/<short_id>+', endpoint='short_link_details')
])
```
路由用于匹配和解析 url，Werkzeug 提供了一个灵活的集成路由，需要自己添加一些列的 Rule 对象到 Map 实例中，每个 rule 会匹配 url 并添加一个 endpoint。
而 endpoint 通常是一个用于标记 url 的字符串。

将 endpoint 指向一个函数：

```python
def dispatch_request(self, request):
   adapter = self.url_map.bind_to_environ(request.environ)
   try:
       endpoint, values = adapter.match()
       return getattr(self, 'on_' + endpoint)(request, **values)
   except HTTPException, e:
       return e
```
将 url_map 绑定到当前的环境并返回一个 URLAdapter。适配器可以用于匹配请求也可以用于翻转 urls。匹配的方法将会返回 endpoint 和一个 URL 的值字典。
如上，在浏览器中输入 `http://localhost:5000/foo` 将会得到如下的值：

```python
endpoint = 'follow_short_link'
values = {'short_id': u'foo'}
```

如果 adapter 没有匹配到任何东西，他将会抛出一个 NotFound 异常，实质上是一个 HTTPException 异常。所有的 HTTP 异常将会跳转到 WSGI 应用渲染的默认错误页面。

### 5 第一个视图

```python
def on_new_url(self, request):
    error = None
    url = ''
    if request.method == 'POST':
        url = request.form['url']
        if not is_valid_url(url):
            error = 'Please enter a valid URL'
        else:
            short_id = self.insert_url(url)
            return redirect('/%s+' % short_id)
    return self.render_template('new_url.html', error=error, url=url)


def is_valid_url(url):
    parts = urlparse.urlparse(url)
    return parts.scheme in ('http', 'https')


def insert_url(self, url):
    short_id = self.redis.get('reverse-url:' + url)
    if short_id is not None:
        return short_id
    url_num = self.redis.incr('last-url-id')
    short_id = base36_encode(url_num)
    self.redis.set('url-target:' + short_id, url)
    self.redis.set('reverse-url:' + url, short_id)
    return short_id


def base36_encode(number):
    assert number >= 0, 'positive integer required'
    if number == 0:
        return '0'
    base36 = []
    while number != 0:
        number, i = divmod(number, 36)
        base36.append('0123456789abcdefghijklmnopqrstuvwxyz'[i])
    return ''.join(reversed(base36))
```

### 6 重定向视图

重定向视图的作用是从 redis 中读取一个 url 并跳转到它。另外还会给对应的统计数字增加 1.

```python
def on_follow_short_link(self, request, short_id):
    link_target = self.redis.get('url-target:' + short_id)
    if link_target is None:
        raise NotFound()
    self.redis.incr('click-count:' + short_id)
    return redirect(link_target)
```
如果 url 不存在，则会抛出一个 NotFound 异常。通过 dispatch_request 会返回一个 404 响应。

### 7 描述视图

```python
def on_short_link_details(self, request, short_id):
    link_target = self.redis.get('url-target:' + short_id)
    if link_target is None:
        raise NotFound()
    click_count = int(self.redis.get('click-count:' + short_id) or 0)
    return self.render_template('short_link_details.html',
        link_target=link_target,
        short_id=short_id,
        click_count=click_count
    )
```
