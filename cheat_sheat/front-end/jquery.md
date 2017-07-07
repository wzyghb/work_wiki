
## Why JQuery

1. 消除浏览器之间的差异
2. 简洁地操作 DOM 的方法
3. 轻松实现动画、修改 CSS 等操作

## 选择器

```html
<div class="testing">
    <ul class="lang">
        <li class="lang-javascript">JavaScript</li>
        <li class="lang-python">Python</li>
        <li class="lang-lua">Lua</li>
    </ul>
</div>
```

| id  | 方法 | 例子 |
|:--- |:--- |:--- |
| 1 | 按照 ID 查找 | `$('#abc')` |
| 2 | 按照 tag 查找 | `$('p')` |
| 3 | 按照 class 查找 | `$('.red')` or `$('.red.green')` |
| 4 | 按照属性查找 | `$('[name=email]')` or `$('[name^=icon]')` |
| 5 | 各种组合查找 | `$('input[name=email]')` or `$('tr.red')` |
| 6 | 多个选择 | `$('p,div')` or `$('p.red,p.green')` |
| 7 | 层级选择器 | `$('ul.lang li.lang-javascript')` or `$('form[name=upload] input')` |
| 8 | 子选择器 | `$('ul.lang>li.lang-javascript')` |
| 9 | 过滤器 | `$('ul.lang li:nth-child(2)')` |

按照属性查找可以表示为：
1. 以某种方式开头
2. 以某种方式结尾
3. 包含某些内容

层级选择器要求满足关系的节点具有层级关系即可，而父子选择器则严格要求必须为父子关系。

## 查找和过滤

+ `find(xxx)` xxx 具有和选择器类似的方法
+ `parent()` 获得此处的原节点
+ `next()` 
+ `filter(xxx)` xxx 是字符串时，和 find 类似，也可以传入一个函数
+ `map()`


## 操作 dom

+ 修改 text
+ 修改 html
+ 修改 css
+ 显示隐藏 DOM
+ 操作表单
+ 添加 DOM
+ 删除 DOM


## 事件

+ 绑定事件
+ 取消绑定事件
+ 

## 动画

+ `hide`、`show`
+ `slideUp`、`slideDown`
+ `fadeIn`、`fadeOut`
+ `animate`
+ `delay`


## AJAX Asynchronous JavaScript and XML

### `XMLHttpRequest` 对象

所有的 AJAX 都是异步执行的，通过回调函数来获得响应：

```javascript
function success(text) {
    var textarea = document.getElementById('test-response-text');
    textarea.value = text;
}

function fail(code) {
    var textarea = document.getElementById('test-response-text');
    textarea.value = 'Error code: ' + code;
}

var request = new XMLHttpRequest(); // 新建XMLHttpRequest对象

request.onreadystatechange = function () { // 状态发生变化时，函数被回调
    if (request.readyState === 4) { // 成功完成
        // 判断响应结果:
        if (request.status === 200) {
            // 成功，通过responseText拿到响应的文本:
            return success(request.responseText);
        } else {
            // 失败，根据响应码判断失败原因:
            return fail(request.status);
        }
    } else {
        // HTTP请求还在继续...
    }
}

// 发送请求:
request.open('GET', '/api/categories');
request.send();

alert('请求已发送，请等待响应...');
```

浏览器的具有同源策略，默认情况下，JavaScript 在发送 AJAX 请求时，URL 的域名必须和当前页面完全一致。
使用 JavaScript 访问外域的方法：
1. 通过 Flash 插件
2. 在同源域名下假设一个代理服务器
3. JSONP，只能用 GET 请求，并且按照要求返回 JavaScript。--- 浏览器允许跨域引用 JavaScript 资源。
4. CORS Cross-Origin Resource Sharing -> HTML5 定义的如何跨域访问资源

## Promise

start function:

```javascript
function task(resolve, reject) {
    xxxx;
    if failed {
        reject(xxx);
    } else {
        resolve(xxx);
    }
}
```
+ `then`
+ `catch`
+ `all`
+ `race`

示例代码：

```javascript

var p = new Promise(function (resolve, reject) {
    log('start new Promise...');
    resolve(123);
});

function multiply(input) {
    return new Promise(function (resolve, reject) {
        log('calculating ' + input + ' x ' + input + '...');
        setTimeout(resolve, 500, input * input);
    });
}

function add(input) {
    return new Promise(function (resolve, reject) {
        log('calculating ' + input + ' + ' + input + '...');
        setTimeout(resolve, 500, input + input);
    });
}

p.then(multiply)
 .then(add)
 .then(multiply)
 .then(add)
 .then(function (result) {
    log('Got value: ' + result);
});


var p1 = new Promise(function (resolve, reject) {
    setTimeout(resolve, 500, 'P1');
});
var p2 = new Promise(function (resolve, reject) {
    setTimeout(resolve, 600, 'P2');
});

// all
Promise.all([p1, p2]).then(function (results) {
    console.log(results); // 获得一个Array: ['P1', 'P2']
});

// race
Promise.race([p1, p2]).then(function (result) {
    console.log(result); // 'P1'
});
```
