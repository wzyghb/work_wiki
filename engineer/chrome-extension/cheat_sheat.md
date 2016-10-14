
Manifest 模板

```json
{
    "app": {
        "background": {
            "scripts": ["background.js"]
        }
    },
    "manifest_version": 2,
    "name": "My Extension",
    "version": "versionString",
    "default_locale": "en",
    "description": "A plain text description",
    "icons": {
        "16": "images/icon16.png",
        "48": "images/icon48.png",
        "128": "images/icon128.png"
    },
    "browser_action": {
        "default_icon": {
            "19": "images/icon19.png",
            "38": "images/icon38.png"
        },
        "default_title": "Extension Title",
        "default_popup": "popup.html"
    },
    "page_action": {
        "default_icon": {
            "19": "images/icon19.png",
            "38": "images/icon38.png"
        },
        "default_title": "Extension Title",
        "default_popup": "popup.html"
    },
    "background": {
        "scripts": ["background.js"]
    },
    "content_scripts": [
        {
            "matches": ["http://www.google.com/*"],
            "css": ["mystyles.css"],
            "js": ["jquery.js", "myscript.js"]
        }
    ],
    "options_page": "options.html",
    "permissions": [
        "*://www.google.com/*"
    ],
    "web_accessible_resources": [
        "images/*.png"
    ]
}
```

### 1 content_scripts
指定将哪些脚本何时注入到哪些页面中，当用户访问这些页面后，相应的脚本即可自动执行，从而对 DOM 进行操作。
`matches`：该属性定义了哪些页面会被注入脚本
`exclude_matches` 定义了哪些页面不会被注入脚本
css 和 js 定义了要注入的样式表和 JavaScript。
`run_at`: 定义了何时运行注入
`all_frame`: 定义脚本是否会注入嵌套式框架中。
`include_globs` 和 `exclude_globs` 是全局 URL 匹配
最终脚本是否会被注入由 `matches`、`exclude_matches`、`include_globs`、`exclude_globs` 的值共同决定。

如果 URL 匹配 matches 的值同时也匹配 `include_globs` 的值，会被注入，如果 URL 匹配 `exclude_matches` 或者 `exclude_globs` 的值则不会被注入。

content_scripts 中的脚本只是共享页面的 DOM，不会共享页面中嵌套的 JavaScript 命名空间。

### 2 跨域请求

JavaScript 通过 XMLHttpRequest 请求数据时，调用 JavaScript 的页面所在的域和被请求的域不一致，
对于网站来讲，浏览器会出于安全考虑不允许跨域。另外对于域相同，但是协议不同、端口不同时，

```json
"permissions": [
    "http://sneezryworks.sinaapp.com/ip.php"
]
```

### 3 常驻后台

在 Manifest 中指定 background 域可以使扩展常驻后台。background 可以包含三种属性，分别是 scripts、page 和 persistent。

指定了 scripts 属性，则 Chrome 会在扩展启动时自动创建一个包含所有指定脚本的页面；
指定了 page 属性，则 Chrome 会将指定的 HTML 文件作为后台页面运行。
通常我们只需要使用 scripts 属性即可，除非在后台页面中需要构建特殊的HTML——但一般情况下后台页面的 HTML 我们是看不到的。

persistent 属性定义了常驻后台的方式——当其值为 true 时，表示扩展将一直在后台运行，无论其是否正在工作；
当其值为 false 时，表示扩展在后台按需运行，这就是 Chrome 后来提出的 `Event Page`。
`Event Page` 可以有效减小扩展对内存的消耗，如非必要，请将 persistent 设置为 false。persistent 的默认值为 true。

### 4 选项页面

Manifest 文件的 options_page 属性可以为开发者提供选项页面。
使用HTML5新增的localStorage接口来保存用户的选项数据。
localStorage是HTML5新增的方法，它允许JavaScript在用户计算机硬盘上永久储存数据（除非用户主动删除）

localStorage 的局限性：
+ localStorage和Cookies类似，都有域的限制，运行在不同域的JavaScript无法调用其他域localStorage的数据。
+ 单个域在localStorage中存储数据的大小通常有限制（虽然W3C没有给出限制），对于Chrome这个限制是5MB
+ localStorage只能储存字符串型的数据，无法保存数组和对象，但可以通过join、toString和JSON.stringify等方法先转换成字符串再储存。

而通过声明 `unlimitedStorage`, Chrome 扩展和应用可以突破这一限制。

### 5 扩展页面的通信

四个有关的扩展页面之间相互通信的接口：
+ runtime.sendMessage
+ runtime.onMessage
+ runtime.connect
+ runtime.onConnect

前两个是初级接口，后两个是高级接口。Chrome 提供的大部分 API 是不能够在 content_scripts 之中运行的，但是 runtime.sendMessage 和 runtime.onMessage
可以在 content_scripts 之中运行，所以扩展的其他页面也可以同 content_scripts 相互通信。

runtime.sendMessage 完整的方法为：
```JavaScript
chrome.runtime.sendMessage(extentionId, message, options)
```
+ extentionId: 所发送消息的目标扩展，如果不设定这个值，默认为发起次消息的扩展本身。
+ message: 要发送的内容，类型随意，内容随意。
+ options: 对象类型，包含一个值为布尔型的 includeTlsChannelId 属性，此属性的值决定扩展发起此消息时是否要将 TLS 通道 ID 发送给监听此消息的外部扩展。

runtime.onMessage 的完整方法为：

```JavaScript
chrome.runtime.onMessage.addListener(callback);
```

此处 callback 为必选的回调函数参数。callback 接收到的参数有三个，分别是 message、sender 和 sendResponse，即消息内容，消息发送者，和响应信息。而
sender 包含四个属性，分别是 tab(发起消息的标签 参见4.5)

### 6 存储数据

chrome 扩展可以通过三种方式进行数据存储：
+ html5 的 localStorage ---- 简单，特殊的 JavaScript 变量
+ chrome 提供的存储 API  ---- 保存任意类型的数据，需要异步调用 Chrome 的 API，结果需要回调函数接收，
+ 使用 Web SQL Database ---- 需要使用 SQL 语句来对数据库进行读写操作。

#### 1 Chrome 存储 API
本身是 localStorage 的改进，与 localStorage 相比区别如下：

+ 如果存储区域指定为 sync, 数据可以自动同步
+ content_scripts 可以直接读取数据，不必通过 background 页面
+ 读写速度快
+ 用户数据可以以对象的类型保存

第二点的解释：localStorage 是基于域名的，而 content_scripts 直接读取 localStorage 所读取到的数据是当前浏览器页面所在域中，通常的解决方案是
content_scripts 通过 runtime.sendMessage 和 background 通信，由 background 读写扩展所在域的 localStorage，然后再传递给 content_scripts。

manifest: permissions storage
chrome storage api 提供了 2 种存储区域，分别是 sync 和 local。sync 存储的区域会根据当前在 chrome 上登陆的 google 账户自动进行同步数据，当没有
sync 区域对数据的读写和 local 区域对数据的读写行为一致。

```
get
getBytesInUse
set
remove
clear
```

```javascript
chrome.storage.StorageArea.get(keys, function(result) {
    console.log(result);
})
```

+ keys 可以使字符串、包含多个字符串的数组或者对象。
+ 字符串：和 localStorage 类似。
+ 数组：一次读取多个数据。
+ 对象：先对去这个对象属性名为键值的数据，不存在则返回 keys 对象的属性值。
+ 空数组[] 或者 {}：则会返回一个空列表。

getBytesInUse 方法为获取一个数据或多个数据所占有的总空间，返回结果的单位是字节，完整的方法是：

```javascript
chrome.storage.StorageArea.getBytesInUse(keys, function(bytes) {
    console.log(bytes);
});
```

此处 keys 只能为 null、字符串或者字符串的数组。

set 方法为写入数据，完整方法为：

```javascript
chrome.storage.StorageArea.set(items, function() {
    // do something
});
```

items 为对象类型，形式为键值对，items 的属性值如果是字符串、数字型和数组型，则存储的格式不会改变，但如果是对象型和函数型，会被存储为 "{}", 如果是日期型和正则型，会存储为
它们的字符串形式。

remove 方法为删除数据：

```javascript
chrome.storage.StorageArea.remove(keys, function() {
    // do something
});
```

keys: 可以是字符串和包含多个字符串的数组。

clear 为删除所有的数据，完整方法为：

```javascript
chrome.storage.StorageArea.clear(function() {
    // do something
});
```

上述方法中，StorageArea 必须是 local 或者 sync。

#### 2 Web SQL Database

+ openDatabase
+ transaction
+ executeSql

```javascript
db = openDatabase("db_name", "0.1", "This is a test db.", 1024*1024);
if(!db){
    alert('数据库连接失败。');
}
else {
    db.transaction( function(tx) {
        tx.executeSql(
            "SELECT COUNT(*) FROM db_name",
            [],
            function(tx, result){
                console.log(result);
            },
            function(tx, error){
                alert('查询失败：'+error.message);
            }
        );
    }
}
```

### Browser Actions

#### 1 图标

```javascript
browser_action.default_icon ->

chrome.browserAction.setIcon(details, callback);
```

details: imageData、path、tabId

#### 2 Popup 页面

+ 关闭后完全停止运行，重启后 js 和 dom 均重置。需要 background 域来声明运行后台脚本。
+ 可以自动显示合适的大小，但是为改善体验，建议设定大小。 建议高度不要超过 500px；且要通过 js 获取当前屏幕的尺寸后进一步修改。
+ 不要模仿 chrome 原始的 UI。
+ 使用带有滚动条的 div 容器，overflow-y 设置为 auto。
    - 设计好的滚动条样式，与自己的应用保持一致的风格
    - 考虑屏蔽右键菜单
    - 使用引用来访问外部脚本

#### 3 标题和 badge

```javascript
"browser_action": {
    "default_title": "Extension Title"
}

chrome.browserAction.setTitle({title: 'This is a new title'});
```

#### 4 右键菜单

右键菜单提供了四中类型，分别是 普通菜单，复选菜单，单选菜单和分割线，其中普通菜单还可以有下级菜单。

```javascript
chrome.contextMenus.create({
    type: 'normal',
    title: 'Menu A',
    id: 'a'
});

chrome.contextMenus.create({
    type: 'radio',
    title: 'Menu B',
    id: 'b',
    checked: true
});

chrome.contextMenus.create({
    type: 'radio',
    title: 'Menu C',
    id: 'c'
});

chrome.contextMenus.create({
    type: 'checkbox',
    title: 'Menu D',
    id: 'd',
    checked: true
});

chrome.contextMenus.create({
    type: 'separator'
});

chrome.contextMenus.create({
    type: 'checkbox',
    title: 'Menu E',
    id: 'e'
});

chrome.contextMenus.create({
    type: 'normal',
    title: 'Menu F',
    id: 'f',
    parentId: 'a'
});

chrome.contextMenus.create({
    type: 'normal',
    title: 'Menu G',
    id: 'g',
    parentId: 'a'
});
```

总结：
+ type: 'normal | radio | checkbox | separator'
+ id
+ title
+ parentId
+ checked

右键菜单的自定义

```javascript
chrome.contextMenus.create({
    type: 'normal',
    title: 'My Menu',
    contexts: ['link']
});
```

contexts 域的值是数组型的，也就是说可以在多种情况下显示自定义菜单，完整的选项包括 `all`,`page`,`frame`,`selection`,`link`,`editable`,`image`,`video`,
`autio` 和 `launcher`, 默认情况下是`page`，即对所有的页面唤出右键菜单是都显示自定义菜单。其中 launcher 只对 Chrome 应用有效。如果包含 launcher 选项，
那么用户在 chrome://apps/ 或者其他地方的应用图标点击右键，将显示相应的自定义菜单。需要注意的是，all 选项不包含 launcher。

documentUrlPatterns 允许限定页面的 URL，只在特定的 url 网站上显示自定义的菜单。 targetUrlPatterns 和 documentUrlPatterns 差不多，但是它所限定的不是标签
的 URL，而是诸如图片、视频和音频等资源的 URL。

如果在创建菜单时，定义了 onclick 域，则菜单被点击后就会调用 onclick 指定的函数。调用的函数会接收到两个参数，分别是点击后相关信息和当前标签的信息。

点击后的相关信息：菜单 id、上级菜单 id，媒体类型 (image\video\audio)，超级链接目标，媒体URL，页面URL，框架URL，选择的文字，是否可编辑。。。。

update 方法可以动态更改菜单属性，指定需要更改菜单的 id 和所需要更改的属性即可。remove 方法可以删除指定的菜单，removeAll 方法可以删除所有的菜单。

例子：只有当用户选择了文本才会显示这个菜单：

```javascript
chrome.contextMenus.create({
    type: 'normal',
    title: '使用Google翻译……',
    id: 'cn',
    contexts: ['selection']
});
```

自定义翻译

```javascript
function translate(info, tab){
    var url = 'http://translate.google.com.hk/#auto/zh-CN/'+info.selectionText ;
    window.open(url, '_blank');
}

chrome.contextMenus.create({
    type: 'normal',
    title: '使用Google翻译……',
    contexts: ['selection'],
    id: 'cn',
    onclick: translate
});
```

### 桌面提醒

实验失败

### Omnibox 多功能框

+ onInputStarted  用户开始输入
+ onInputChanged  输入变化
+ onInputEntered  执行命令
+ onInputCancelled  取消输入行为

这个也实验失败

### page Actions

和 Browser Actions 的区别
+ 没有 badge
+ 不是一直显示图标，独有 show 和 hide 方法

```javascript
chrome.pageAction.show(integer tabId);
chrome.pageAction.hide(integer tabId);
```
tabId为标签id，可以通过tabs接口获取，有关tab相关的内容将在后面进行讲解.


## 浏览器管理

书签的权限声明：

```javascript
"permissions": [
    "bookmarks"
]
```

属性：
+ id
+ parentId
+ index
+ url
+ title
+ dateAdded
+ dateGroupModified
+ children

