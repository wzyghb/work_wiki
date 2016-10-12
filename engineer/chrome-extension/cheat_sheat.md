
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



