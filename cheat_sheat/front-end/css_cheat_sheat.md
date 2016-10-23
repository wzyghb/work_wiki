

# CSS

### 1 创建

引用外部文件：

```javascript
<head>
<link rel="stylesheet" type="text/css" href="mystyle.css" />
</head>
```

内部样式列表：

```javascript
<head>
<style type="text/css">
  hr {color: sienna;}
  p {margin-left: 20px;}
  body {background-image: url("images/back40.gif");}
</style>
</head>
```

内联样式列表

```javascript
<p style="color: sienna; margin-left: 20px">
This is a paragraph
</p>
```

### 2 背景：

```css
background
background-color 
background-image url(\path\to\image.jpg)
background-attachment
background-position (50% 50% | left\center\right\top\bottom | xxpx yypx)
background-repeat (no-repeat | repeat-y | repeat-x)
```

### 3 文本

```css
color
text-index (-+xxem | 20%)
text-align (left | right | center | justify)
word-spacing (20px; 0.5em)
letter-spacing (20px; -0.5em)
text-transform (none | uppercase | lowercase | capitalize)
text-decoration (none | underline 下划线 | overline 上划线 | line-through 删除线 | blink 闪烁文本)
direction (ltr | rtl)
line-height
```

### 4 字体

通用字体系列（拥有相似外观的字体系统组合）： serif、sans-serif、Monospace、Cursive、Fantasy
特定字体系列

希望文档使用一种 sans-serif 字体但是并不关心是哪一种字体，可以声明如下：
body {font-family: sans-serif;}

建议在所有 font-family 规则中都提供一个通用字体系列。这样就提供了一条后路，在用户代理无法提供与规则匹配的特定字体时，就可以选择一个候选字体。
如果您对字体非常熟悉，也可以为给定的元素指定一系列类似的字体。要做到这一点，需要把这些字体按照优先顺序排列，然后用逗号进行连接：

```css
p {font-family: Times, TimesNR, 'New Century Schoolbook', Georgia, 'New York', serif;}
```

```css
font-style: (normal | italic | oblique)
font-weight: (normal | bold | xxx(100 ~ 900))
font-size: (xxpx | x.xxem; 100%)
font-size-adjust
font-stretch
font-variant
font
```

### 5 CSS 链接
| 标识 | 说明 |
|:---:|:---:|
| a:link        | 普通的、未被访问的链接 |
| a:visited     | 用户已访问的链接 |
| a:hover       | 鼠标指针位于链接的上方 |
| a:active      | 链接被点击的时刻 |

例子：

```css
a:link {color:#FF0000;}		    /* 未被访问的链接 */
a:visited {color:#00FF00;}	    /* 已被访问的链接 */
a:hover {color:#FF00FF;}	    /* 鼠标指针移动到链接上 */
a:active {color:#0000FF;}	    /* 正在被点击的链接 */
```

```css
a:link {text-decoration:none;}
a:visited {text-decoration:none;}
a:hover {text-decoration:underline;}
a:active {text-decoration:underline;}
```

### 5 CSS 列表
允许你放置、改变列表项标志，或者将图像作为列表项的标志。

```css
list-style-type: (circle | square | upper-roman | lower-alpha ...);
list-style-image: url(xxx.gif);
list-style: url(xxx.gif) square inside;
```

### 6 CSS 表格

```css
table, th, td
{
    border: 1px solid blue;
}
```

折叠边框: 将表格边框折叠为单一边框。

```css
table
{
    border-collapse:collapse;
}

table,th, td
{
    border: 1px solid black;
}
```

| 属性 | 描述 |
|:---:|:---:|
| border-collapse | 是否将表格边框合并为单一边框 |
| border-radius | 设置边框圆角 |
| border-spacing | 设置分隔单元格边框的距离 |
| caption-side | 表格标题的位置 |
| empty-cells | 是否显示表格中的空单元格 |
| table-layout | 设置显示单元、列和行的算法 |

### 6 轮廓 （Outline) 实例

```css
p 
{
    border: red solid thin;
    outline:#00ff00 dotted thick;
    border-radius: 0 8px 8px 0;
}
```

```css
outline-style
outline-color
outline-width
```

### css 框模型

```css
border
margin
padding
```

#### 1 内边距

```css
padding-top
padding-right
padding-bottom
padding-left

xxx {padding: 1.5cm}            // 全是 1.5cm 内边距
xxx {padding: 0.5cm 2.5cm}      // 上下是 0.5cm 内边距，左右是 2.5cm 内边距

padding-right: 10%
padding-bottom: 10%
```

#### 2 边框

```css
border-style: none | hidden | dotted | dashed | solid | double | groove | ridge | inset | outset | inherit |
border-top-style
border-right-style
border-bottom-style
border-left-style

border-width
border-top-width
border-right-width
border-bottom-width
border-left-width

border-color
border-top-color
border-right-color
border-bottom-color
border-left-color
```

#### 3 外边框

```css
margin : 0.25in;
margin : 10px 0px 15px 5px;

设置的基本顺序：
margin: top right bottom left

相对于元素的 width 计算百分比：
margin : 10%;

简化定义中的值复制规则：

+ 如果缺少左外边距的值，则使用右外边距的值。
+ 如果缺少下外边距的值，则使用上外边距的值。
+ 如果缺少右外边距的值，则使用上外边距的值。

margin-bottom
margin-left
margin-right
margin-top
```

### css 定位

定位：建立布局，使得元素出现想要的位置。

一切皆为框。

css 有三种基本的定位机制：普通流、浮动和绝对定位。

```
display: (none | block | inline | inline-block | list-item | ... ) 规定元素应该生成的框的类型。

position: (static | relative | absolute | fixed)
left: xxxpx
right： xxxpx
```

例子：使用滚动条来显示元素中溢出的内容：

```css
div 
{
    background-color:#00FFFF;
    width:150px;
    height:150px;
    overflow: scroll;
}
```

```css
overflow: (scroll | hidden | visible | auto | inherit)
```

#### 1 相对定位

#### 2 绝对定位

#### 3 浮动

clear: 定义了元素的哪边上不允许出现浮动元素

```css
img
{
    float: left;
    clear:both;
}
```

left | right | both | none | inherit

### 高级

#### 1 对齐

#### 2 尺寸

```css
height
width
line-height
max-height
max-width
min-height
min-width

cursor: 规定鼠标在当前某元素之上时显示的指针类型。 (cursor:auto | crosshair | default | pointer | move | e-resize | ne-resize | nw-resize | n-resize)
```

#### 3 分类

#### 4 导航栏

使用无序列表来实现

```html
<ul>
<li><a href="default.asp">Home</a></li>
<li><a href="news.asp">News</a></li>
<li><a href="contact.asp">Contact</a></li>
<li><a href="about.asp">About</a></li>
</ul>
```

```css
ul
{
    list-style-type:none;   // 消除无序列表前面的标志符号
    margin:0;
    padding:0;
}

a
{
    display:block;
    width:60px;
}

li
{
    display:inline;
}
```

#### 5 图片库

```css
img
{
    opacity:0.4;
}
img:hover
{
    opacity:1.0;
}
```
`linear-gradient()` 函数创建了一个呈现线性渐变颜色的image

```css
ackground-image: linear-gradient(to bottom, #4d90fe, #4787ed);
```

## 备忘录

### 0 示例代码
```css
white-space: nowrap;   // 规定段落中的文本不进行换行
border-bottom: 1px dashed #69c;    // 定义下面的分割线为虚线
```

### 1 边框
+ none: 无边框
+ hidden: 无边框，解决边框冲突
+ dotted: 定义点状边框
+ dashed: 定义虚线，在大多数浏览器中呈现为实现
+ solid: 定义实线
+ double: 定义双线，双线的宽度等于 border-width
+ groove: 定义 3D 凹槽边框，其效果取决于 border-color 的值
+ ridge、inset、outset、inherit
