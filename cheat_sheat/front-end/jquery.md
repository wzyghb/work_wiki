
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


## AJAX

+ 