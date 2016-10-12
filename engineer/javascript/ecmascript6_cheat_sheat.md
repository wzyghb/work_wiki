
# 1. 简介

## 安装

```python
curl -o- https://raw.githubusercontent.com/creationix/nvm/<version number>/install.sh | bash
# 激活
source ~/.nvm/nvm.sh
nvm install node
nvm use node
```

## Babel 转码器
将 ES6 转码为 ES5

```javascript
// 转码前
input.map(item => item + 1);

// 转码后
input.map(function (item) {
  return item + 1;
});
```

### 配置文件
项目根目录的 `.babelrc`。在使用 Babel 之前需要先配置这个文件。
```javascript
{
  "presets": [],
  "plugins": []
}
```
presets 字段设定了转码规则，官方提供了一些规则集。
```bash
# ES2015转码规则
$ npm install --save-dev babel-preset-es2015

# react转码规则
$ npm install --save-dev babel-preset-react

# ES7不同阶段语法提案的转码规则（共有4个阶段），选装一个
$ npm install --save-dev babel-preset-stage-0
$ npm install --save-dev babel-preset-stage-1
$ npm install --save-dev babel-preset-stage-2
$ npm install --save-dev babel-preset-stage-3
```

在配置文件中加入这些转码规则如下：

```javascript
{
    "presets": [
      "es2015",
      "react",
      "stage-2"
    ],
    "plugins": []
}
```

### 命令行 babel-cli
实现了命令行转码，安装如下：
```
npm install --global babel-cli
```

基本用法
```javascript
# 转码结果输出到标准输出
$ babel example.js

# 转码结果写入一个文件
# --out-file 或 -o 参数指定输出文件
$ babel example.js --out-file compiled.js
# 或者
$ babel example.js -o compiled.js

# 整个目录转码
# --out-dir 或 -d 参数指定输出目录
$ babel src --out-dir lib
# 或者
$ babel src -d lib

# -s 参数生成source map文件

```
$ babel src -d lib -s
```
将babel-cli安装在项目之中

# 安装

```
$ npm install --save-dev babel-cli
```
然后改写`package.json`

```javascript
{
  // ...
  "devDependencies": {
    "babel-cli": "^6.0.0"
  },
  "scripts": {
    "build": "babel src -d lib"
  },
}
```
转码的时候只需执行：

```
npm run build
```

### babel-node

### babel-register
会改写 require 命令，自动加上一个钩子，在使用 require 加载 .js, .jsx, es和 es6 时，会先用 Babel进行转码。

### babel-core

```javascript
var es6Code = 'let x = n => n + 1';
var es5Code = require('babel-core')
  .transform(es6Code, {
    presets: ['es2015']
  })
  .code;
```

### babel-polyfill
Babel默认只转换新的JavaScript句法（syntax），
而不转换新的API，比如Iterator、Generator、Set、Maps、Proxy、Reflect、Symbol、Promise等全局对象，
以及一些定义在全局对象上的方法（比如Object.assign）都不会转码。

必须使用babel-polyfill，为当前环境提供一个垫片.

```javascript
npm install --save babel-polyfill

import 'babel-polyfill';
// 或者
require('babel-polyfill');
```

### 浏览器环境

从Babel 6.0开始，不再直接提供浏览器版本，而是要用构建工具构建出来。

### 在线环境
[地址](https://babeljs.io/)

### 与其他工具配合

eslint
mocha

## Traceur 转码器

# let 和 const 命令

var 和 let 的区别：

```javascript
var a = [];
for (var i = 0; i < 10; i++) {
  a[i] = function () {
    console.log(i);
  };
}
a[6](); // 10

var a = [];
for (let i = 0; i < 10; i++) {
  a[i] = function () {
    console.log(i);
  };
}
a[6](); // 6
```

let 不存在变量提升作用，因而所有变量均需要在声明后使用。

暂时性死区： 只要块级作用域内存在let命令，它所声明的变量就“绑定”（binding）这个区域，不再受外部的影响。

```javascript
var tmp = 123;

if (true) {
  tmp = 'abc'; // ReferenceError
  let tmp;
}
```

在代码块内，使用let命令声明变量之前，该变量都是不可用的。这在语法上，称为“暂时性死区”（temporal dead zone，简称TDZ）。
不允许重复声明，let 不允许在相同的作用域内重复声明一个变量。
