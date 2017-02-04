
### npm 命令

+ npm -v
+ npm install <Module Name>       # 
+ npm install <Module Name> -g    # 全局安装
+ npm config set proxy
+ npm ls -g
+ npm uninstall express
+ npm update [-g]
+ npm search
+ npm init
+ npm adduser
+ npm publish
+ npm cache clear
+ npm unpublish <package>@<version>
+ npm install -g cnpm --registry=https://registry.npm.taobao.org （使用 npm 淘宝镜像)

package.json

```
name: 包名
version: 包的版本号
description: 包的描述
homepage: 包的官网 url
author: 包的作者姓名
contributors: 包的其他贡献者
dependencies: 依赖的包列表，如果没有安装，npm 会自动安装到 node_modules 目录下
repository: 保代码存放的地方，如 github、svn
main: 主要项目
keywords: 关键字
```

### nodejs 模块解析路径

内置模块
node_modules 目录
NODE_PATH 环境变量

### 包管理

典型的目录结构
```
cat/
    doc/
    lib/
        head.js
        body.js
        main.js
        ...
    test/
    package.json
```

package.json 中指定内容：

```json
{
    "name": "cat",
    "main": "./lib/main.js"
}
```

使用：
```
require('/home/user/lib/cat');
```

### 工程目录

```
xxx/project/                # 工程目录
    bin/                    # 存放命令行相关代码
        node-echo           # 注意此处可以是典型的脚本程序
    doc/
    lib/                    # 存放 API 相关代码
        echo.js
    node_modules/           # 存放三方的包
        argv/
    tests/                  # 测试用例
    package.json            # 原数据文件
    README.md               # 说明文件
```

### npm

+ npm install xxx
+ npm adduser
+ npm publish
+ npm help
+ npm update
+ npm cache

### 文件操作

示例代码：
```
var fs = require("fs");

fs.writeFileSync(dst, data);
fs.readFileSync(src);

// 大文件
fs.createReadStream(src).pipe(fs.createWriteStream(dst));
```

其他 API

[Buffer 数据块]( http://nodejs.org/api/buffer.html)

```javascript
var bin = new Buffer([ 0x68, 0x65, 0x6c, 0x6c, 0x6f ]);
bin[0]; // => 0x68;
var str = bin.toString('utf-8'); // => "hello"
var bin = new Buffer('hello', 'utf-8'); // => <Buffer 68 65 6c 6c 6f>
var bin = new Buffer([ 0x68, 0x65, 0x6c, 0x6c, 0x6f ]);
var sub = bin.slice(2);

var bin = new Buffer([ 0x68, 0x65, 0x6c, 0x6c, 0x6f ]);
var dup = new Buffer(bin.length);
bin.copy(dup);
```

[Stream 数据流](http://nodejs.org/api/stream.html)

Stream 基于事件工作，所有的 Stream 实例都继承于 NodeJS 提供的 EventEmitter。

```javascript
var rs = fs.createReadStream(pathname);

rs.on('data', function (chunk) {
    // 不管能够处理过来的方案
    doSomething(chunk);

    // 改进
    rs.pause();
    doSomething(chunk, function () {
        rs.resume();
    });
});

rs.on('end', function () {
    cleanUp();
});
```

```javascript
var rs = fs.createReadStream(src);
var ws = fs.createWriteStream(dst);

rs.on('data', function (chunk) {
    if (ws.write(chunk) === false) {        // 判断数据是写入目标了还是临时放在缓存了
        rs.pause();
    }
});

rs.on('end', function () {
    ws.end();
});

ws.on('drain', function () {                // 判断数据流是否将缓存中的数据写入目标，是否可以传入下一个待写入的数据了
    rs.resume();
});
```

[File Stream 文件系统](http://nodejs.org/api/fs.html)

```
fs.stat
fs.chmod
fs.chown
fs.readFile
fs.readdir
fs.writeFile
fs.mkdir
fs.open
fs.read
fs.write
fs.close
```

回调代码示例：

```javascript
fs.readFile(pathname, function (err, data) {
    if (err) {
        // Deal with error.
    } else {
        // Deal with data.
    }
});
```

[path 路径](http://nodejs.org/api/path.html)

```
path.normalize
path.join
path.extname
```

示例代码： 同步目录的遍历

```javascript
function travel(dir, callback) {
    fs.readdirSync(dir).forEach(function (file) {
        var pathname = path.join(dir, file);

        if (fs.statSync(pathname).isDirectory()) {
            travel(pathname, callback);
        } else {
            callback(pathname);
        }
    });
}
```

示例代码：异步目录的遍历

```javascript
function travel(dir, callback, finish) {
    fs.readdir(dir, function (err, files) {
        (function next(i) {
            if (i < files.length) {
                var pathname = path.join(dir, files[i]);

                fs.stat(pathname, function (err, stats) {
                    if (stats.isDirectory()) {
                        travel(pathname, callback, function () {
                            next(i + 1);
                        });
                    } else {
                        callback(pathname, function () {
                            next(i + 1);
                        });
                    }
                });
            } else {
                finish && finish();
            }
        }(0));
    });
}
```

### 网络操作

```javascript
var http = require('http');

http.createServer(function (request, response) {
    response.writeHead(200, { 'Content-Type': 'text-plain' });
    response.end('Hello World\n');
}).listen(8124);
```

API 简要介绍

[HTTP](http://nodejs.org/api/http.html)

作为服务端使用，创建一个 HTTP 服务器，并且监听 HTTP 客户端的请求并返回响应：

1

```javascript
http.createServer(function (request, response) {
    var body = [];

    console.log(request.method);
    console.log(request.headers);

    request.on('data', function (chunk) {
        body.push(chunk);
    });

    request.on('end', function () {
        body = Buffer.concat(body);
        console.log(body.toString());
    });
}).listen(80);
```

2

```javascript
http.createServer(function (request, response) {
    response.writeHead(200, { 'Content-Type': 'text/plain' });

    request.on('data', function (chunk) {
        response.write(chunk);
    });

    request.on('end', function () {
        response.end();
    });
}).listen(80);
```

作为客户端使用

```javascript
var options = {
        hostname: 'www.example.com',
        port: 80,
        path: '/upload',
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        }
    };

var request = http.request(options, function (response) {});        // 创建客户端并指定报头和响应文件

request.write('Hello World');
request.end();
```

更贱便捷的请求 API

```javascript
http.get('http://www.example.com/', function (response) {});
```

[HTTPS](http://nodejs.org/api/https.html)

作为服务器

```javascript
var options = {
    key: fs.readFileSync('./ssl/default.key'),
    cert: fs.readFileSync('./ssl/default.cer')
};

var server = https.createServer(options, function (request, response) {
    // ...
});
```

和 http 相比多了一个 key 和 cert 字段用于获取 HTTPS 服务器使用的私钥和公钥。

使用 NodeJS 支持的 SNI 技术，可以根据 HTTPS 客户端请求使用的域名动态添加多组证书如下：

```javascript
server.addContext('foo.com', {
    key: fs.readFileSync('./ssl/foo.com.key'),
    cert: fs.readFileSync('./ssl/foo.com.cer')
});

server.addContext('bar.com', {
    key: fs.readFileSync('./ssl/bar.com.key'),
    cert: fs.readFileSync('./ssl/bar.com.cer')
});
```

作为客户端

```javascript
var options = {
        hostname: 'www.example.com',
        port: 443,
        path: '/',
        method: 'GET'
    };

var request = https.request(options, function (response) {});

request.end();
```

自制 SSL 证书的配置：

options 中加入 `rejectUnauthorized: false` 字段。

[URL](http://nodejs.org/api/url.html)

解析URL

非完整的 URL 也可以使用 parse 方法来解析，如:
```javascript
url.parse('http://user:pass@host.com:8080/p/a/t/h?query=string#hash');

// 结果：
Url {
  protocol: 'http:',
  slashes: true,
  auth: 'user:pass',
  host: 'host.com:8080',
  port: '8080',
  hostname: 'host.com',
  hash: '#hash',
  search: '?query=string',
  query: 'query=string',
  pathname: '/p/a/t/h',
  path: '/p/a/t/h?query=string',
  href: 'http://user:pass@host.com:8080/p/a/t/h?query=string#hash' }
```
.parse 第二个参数： 是否使用 querystring 模块进一步解析 query 字段。第三个字段为 true 时，方法可以解析不带协议头的 URL ，如 `//www.example.com/foo/bar`

生成URL

.format 方法将 URL 对象转化为 url 字符串：

```javascript
url.format({
    protocol: 'http:',
    host: 'www.example.com',
    pathname: '/p/a/t/h',
    search: 'query=string'
});
/* =>
'http://www.example.com/p/a/t/h?query=string'
*/
```

拼接URL

```javascript
url.resolve('http://www.example.com/foo/bar', '../baz');
/* =>
http://www.example.com/baz
*/
```

[Query String](http://nodejs.org/api/querystring.html)

```javascript
querystring.parse('foo=bar&baz=qux&baz=quux&corge');
/* =>
{ foo: 'bar', baz: ['qux', 'quux'], corge: '' }
*/

querystring.stringify({ foo: 'bar', baz: ['qux', 'quux'], corge: '' });
/* =>
'foo=bar&baz=qux&baz=quux&corge='
*/
```

[zlib](http://nodejs.org/api/zlib.html)

zlib模块提供了数据压缩和解压的功能。

服务器：
```javascript
http.createServer(function (request, response) {
    var i = 1024,
        data = '';

    while (i--) {
        data += '.';
    }

    if ((request.headers['accept-encoding'] || '').indexOf('gzip') !== -1) {    // 是否永续 gzip 格式
        zlib.gzip(data, function (err, data) {          // 使用 zlib.gzip 格式进行压缩
            response.writeHead(200, {
                'Content-Type': 'text/plain',
                'Content-Encoding': 'gzip'
            });
            response.end(data);
        });
    } else {
        response.writeHead(200, {
            'Content-Type': 'text/plain'
        });
        response.end(data);
    }
}).listen(80);
```

客户端

```javascript
var options = {
        hostname: 'www.example.com',
        port: 80,
        path: '/',
        method: 'GET',
        headers: {
            'Accept-Encoding': 'gzip, deflate'
        }
    };

http.request(options, function (response) {
    var body = [];

    response.on('data', function (chunk) {
        body.push(chunk);
    });

    response.on('end', function () {
        body = Buffer.concat(body);

        if (response.headers['content-encoding'] === 'gzip') {
            zlib.gunzip(body, function (err, data) {
                console.log(data.toString());
            });
        } else {
            console.log(data.toString());
        }
    });
}).end();
```

[net 创建 Socket 服务端和客户端](http://nodejs.org/api/net.html)

### 进程管理

```javascript
var child_process = require('child_process');
var util = require('util');

function copy(source, target, callback) {
    child_process.exec(
        util.format('cp -r %s/* %s', source, target), callback);
}

copy('a', 'b', function (err) {
    // ...
});
```

API

+ [Process](http://nodejs.org/api/process.html)
+ [Child Process](http://nodejs.org/api/child_process.html)
+ [Cluster](http://nodejs.org/api/cluster.html)

获取命令行参数： process.argv 自身占有 0 和 1 两个参数，用户参数从 2 开始。
退出程序：process.exit(1)
标准输入：process.stdin 标准输出 process.stdout 标准错误 process.error
降低系统权限：process.setgid process.setuid

创建子进程 `.spawn(exec, args, options)`

```javascript
var child = child_process.spawn('node', [ 'xxx.js' ]);

child.stdout.on('data', function (data) {
    console.log('stdout: ' + data);
});

child.stderr.on('data', function (data) {
    console.log('stderr: ' + data);
});

child.on('close', function (code) {
    console.log('child process exited with code ' + code);
});
```

进程间通讯

kill 发送消息

```javascript
/* parent.js */
var child = child_process.spawn('node', [ 'child.js' ]);

child.kill('SIGTERM');

/* child.js */
process.on('SIGTERM', function () {
    cleanUp();
    process.exit(0);
});
```

### 异步编程

[域 Domain](http://nodejs.org/api/domain.html)
简化异步代码的异常处理

没有域的代码异常处理使用回调函数如下所示：

```javascript
function async(request, callback) {
    // Do something.
    asyncA(request, function (err, data) {
        if (err) {
            callback(err);
        } else {
            // Do something
            asyncB(request, function (err, data) {
                if (err) {
                    callback(err);
                } else {
                    // Do something
                    asyncC(request, function (err, data) {
                        if (err) {
                            callback(err);
                        } else {
                            // Do something
                            callback(null, data);
                        }
                    });
                }
            });
        }
    });
}

http.createServer(function (request, response) {
    async(request, function (err, data) {
        if (err) {
            response.writeHead(500);
            response.end();
        } else {
            response.writeHead(200);
            response.end(data);
        }
    });
});
```

domain 模块创建一个子域，在子域内运行的代码可以随意地抛出异常，这些异常可以通过子域对象的 error 事件统一进行处理。

```javascript
function async(request, callback) {
    // Do something.
    asyncA(request, function (data) {
        // Do something
        asyncB(request, function (data) {
            // Do something
            asyncC(request, function (data) {
                // Do something
                callback(data);
            });
        });
    });
}

http.createServer(function (request, response) {
    var d = domain.create();

    d.on('error', function () {
        response.writeHead(500);
        response.end();
    });

    d.run(function () {
        async(request, function (data) {
            response.writeHead(200);
            response.end(data);
        });
    });
});
```

更多的示例代码

异步遍历数组，且一个接一个串行处理。

```javascript
(function next(i, len, callback) {
    if (i < len) {
        async(arr[i], function (value) {
            arr[i] = value;
            next(i + 1, len, callback);
        });
    } else {
        callback();
    }
}(0, arr.length, function () {
    // All array items have processed.
}));
```
### 异常处理的陷阱

无论是通过process对象的uncaughtException事件捕获到全局异常，还是通过子域对象的 
error 事件捕获到了子域异常，在NodeJS官方文档里都强烈建议处理完异常后立即重启程序，
而不是让程序继续运行。按照官方文档的说法，发生异常后的程序处于一个不确定的运行状态，
如果不立即退出的话，程序可能会发生严重内存泄漏，也可能表现得很奇怪。

JS本身的throw..try..catch异常处理机制并不会导致内存泄漏，也不会让程序的执行结果出乎意料，
但NodeJS并不是存粹的JS。NodeJS里大量的API内部是用C/C++实现的，因此NodeJS程序的运行过程中，
代码执行路径穿梭于JS引擎内部和外部，而JS的异常抛出机制可能会打断正常的代码执行流程，
导致C/C++部分的代码表现异常，进而导致内存泄漏等问题。
