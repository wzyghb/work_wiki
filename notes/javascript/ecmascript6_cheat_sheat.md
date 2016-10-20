
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


### 字符串

+ charCodeAt
+ codePointAt
+ String.fromCharCode
+ 字符串遍历接口 for (let codepoint of str) { ... }

```javascript
var text = String.fromCodePoint(0x20BB7);

for (let i = 0; i < text.length; i++) {
  console.log(text[i]);
}
// " "
// " "

for (let i of text) {
  console.log(i);
}
```

+ normalize
+ include
+ startsWith
+ endsWith
+ repeat
+ padStart
+ padEnd

### 数组扩展

+ Array.from()
+ Array.of()
+ Array.prototype.copyWithin(target, start, end)
+ find, findIndex, fill(value, start, end)
+ keys(), values(), entries()
+ includes
+ Map.prototype.has(key)、WeakMap.prototype.has(key)、Reflect.has(target, propertyKey)
+ Set.prototype.has(value)、WeakSet.prototype.has(value)
+ forEach(), filter(), every() 和some()都会跳过空位。
+ map()会跳过空位，但会保留这个值
+ join()和toString()会将空位视为undefined，而undefined和null会被处理成空字符串。
+ Array.from方法会将数组的空位，转为undefined
+ for...of循环也会遍历空位。
+ fill()会将空位视为正常的数组位置。
+ entries()、keys()、values()、find()和findIndex()会将空位处理成undefined。

### 函数扩展

javascript 中函数的默认值。
javascript 默认值和解构相结合。
双重默认值
函数的 length 属性是函数参数中没有默认值的参数个数。
rest 参数 *args
扩展运算符 

### 对象的扩展

Object.is
Object.assign
描述对象：Object.getOwnPropertyDescriptor
属性的遍历：
  - for .. in
  - Object.keys() Object.values() Object.entries()
  - Object.getOwnPropertyDescriptyNames(obj)
  - Object.getOwnPropertyDescriptySymbols(obj)
  - Reflect.ownKeys(obj)
__proto__, Object.setPrototypeOf(), Object.getPrototypeOf(), Object.create()

### Symbol

+ 表示独一无二
+ Symbol 不能与其他值进行运算
+ 可以显示转化为字符串和布尔型，但是不能转化为数字。

Symbol 可以作为对象的属性名。Symbol值作为对象属性名时，不能用点运算符

```javascript
var sym = Symbol("foo")
a[sym] = "value"

a[sym]
```


javascript 中的其中数据类型： Undefined\Null\Boolean\String\Number\Object\Symbol


## Promise

三个状态：Pending\Resolved\Rejected

特点：
1. 对象的状态不受外界的影响
2. 一旦状态改变，就不会再变

优点： 简化了异步操作
1. 将异步操作以同步操作的形式表示出来，避免层层套嵌的回调函数
2. 提供了统一的接口

缺点：
1. 无法取消
2. 如果没有回调函数，内部错误不会反馈到外部
3. 处于 Pending 状态时，不确定执行的实时状态

> Stream vs Promise

例子：

#### 生成 Promise 实例

```javascript
var promise = new Promise(function(resolve, reject) {
  // ... some code

  if (/* 异步操作成功 */){
    resolve(value);
  } else {
    reject(error);
  }
});
```

+ resolve: 将Promise对象的状态从 `Pending` 变为 `Resolved`。
+ reject: 将Promise对象的状态从 `Pending` 变为 `Rejected`。

#### then 方法：对实例指定 Resolved 和 Reject 状态的回调函数

```javascript
promise.then(function(value) {
  // success
}, function(error) {
  // failure
});
```


#### Promise.prototype.catch方法是.then(null, rejection)的别名

如果Promise状态已经变成Resolved，再抛出错误是无效的。例子：

```javascript
var promise = new Promise(function(resolve, reject) {
  resolve('ok');
  throw new Error('test');
});
promise
  .then(function(value) { console.log(value) })
  .catch(function(error) { console.log(error) });
```

一般来说，不要在then方法里面定义Reject状态的回调函数（即then的第二个参数），总是使用catch方法。
跟传统的try/catch代码块不同的是，如果没有使用catch方法指定错误处理的回调函数，Promise对象抛出的错误不会传递到外层代码，即不会有任何反应。(注意，Chrome浏览器不遵守这条规定，它会抛出错误“ReferenceError: x is not defined”。)

unhandledRejection事件，专门监听未捕获的reject错误。例子：

```javascript
process.on('unhandledRejection', function (err, p) {
  console.error(err.stack)
});
```

unhandledRejection事件的监听函数有两个参数，第一个是错误对象，第二个是报错的Promise实例，它可以用来了解发生错误的环境信息。

#### Promise.all()

将多个 Promise 实例合并。

+ 只有p1、p2、p3的状态都变成fulfilled，p的状态才会变成fulfilled，此时p1、p2、p3的返回值组成一个数组，传递给p的回调函数。
+ 只要p1、p2、p3之中有一个被rejected，p的状态就变成rejected，此时第一个被reject的实例的返回值，会传递给p的回调函数。

例子

```javascript
// 生成一个Promise对象的数组
var promises = [2, 3, 5, 7, 11, 13].map(function (id) {
  return getJSON("/post/" + id + ".json");
});

Promise.all(promises).then(function (posts) {
  // ...
}).catch(function(reason){
  // ...
});
```

#### Promise.race()

```javascript
var p = Promise.race([p1,p2,p3]);
```

只要p1、p2、p3之中有一个实例率先改变状态，p的状态就跟着改变。那个率先改变的Promise实例的返回值，就传递给p的回调函数。

#### Promise.resolve()

将现有的对象转化为 Promise 对象。

```javascript
var jsPromise = Promise.resolve($.ajax('/whatever.json'));

Promise.resolve('foo')
// 等价于
new Promise(resolve => resolve('foo'))
```

有以下四种情况：

##### 1 如果参数是Promise实例，那么Promise.resolve将不做任何修改、原封不动地返回这个实例。
##### 2 参数是一个具有 then 方法的 thenable 对象。

```javascript
let thenable = {
  then: function(resolve, reject) {
    resolve(42);
  }
};

let p1 = Promise.resolve(thenable);
p1.then(function(value) {
  console.log(value);  // 42
});
```
##### 3 参数不是具有then方法的对象，或根本就不是对象，则Promise.resolve方法返回一个新的Promise对象，状态为Resolved。

##### 4 不带任何参数

#### Promise.reject()

```javascript
var p = Promise.reject('出错了');
// 等同于
var p = new Promise((resolve, reject) => reject('出错了'))

p.then(null, function (s){
  console.log(s)
});
// 出错了
```

#### done 捕获在 Promise 链中没有被捕获的异常

```javascript
asyncFunc()
  .then(f1)
  .catch(r1)
  .then(f2)
  .done();
```

实现非常简单：

```javascript
Promise.prototype.done = function (onFulfilled, onRejected) {
  this.then(onFulfilled, onRejected)
    .catch(function (reason) {
      // 抛出一个全局错误
      setTimeout(() => { throw reason }, 0);
    });
};
```

#### finally

```javascript
server.listen(0)
  .then(function () {
    // run test
  })
  .finally(server.stop);
```

实现：

```javascript
Promise.prototype.finally = function (callback) {
  let P = this.constructor;
  return this.then(
    value  => P.resolve(callback()).then(() => value),
    reason => P.resolve(callback()).then(() => { throw reason })
  );
};
```