# 安全相关

## 参考文章

+ [HTTPS 全面介绍](http://www.wxtlife.com/2016/03/27/%E8%AF%A6%E8%A7%A3https%E6%98%AF%E5%A6%82%E4%BD%95%E7%A1%AE%E4%BF%9D%E5%AE%89%E5%85%A8%E7%9A%84%EF%BC%9F/)

## XSS Cross-Site Script

### 定义

攻击者将客户端的脚本注入到网页中，使得其在其他用户客户端也会生效。一般可分为反射型 XSS 和 存储型 XSS。
反射型 XSS 一般通过构建欺骗的 URL 诱惑用户点击，然后将用户的 cookie 发送给收集器。

### 后续

这可能会导致用户的 cookie、授权信息、密钥等泄露。

### 防止

1. 对用户的输入进行 escape。（各个阶段均可、如存储之前，或者展示给其他用户之前）
1. 将 Cookie 设置为 `http-only`
1. Content-Security-Policy

## CSRF Cross-site Request Forgery

使得用户向被攻击网站发送一个攻击者希望的请求，而用户自己不知道。

简单的身份验证只能保证请求是某个用户的浏览器发出的，不能够保证请求本身是用户自愿发出的。

### 避免 CSRF

+ 只是用 JSON APIs
+ 禁用 CORS
+ `GET` 不应该有副作用
+ CSRF Token
  + 服务端会向客户端发送一个 token，仅附注在表单中
  + 客户端每次提交 form 时，也会发送 token
  + 服务端会对 token 进行检查
  + 只有通过表单正常访问敏感地址才会发送 token
  + flask 中通过设置参数 SECURY_KEY 来生成 csrf-token
+ Referer 字段：标明请求源于哪个地址，敏感数据的请求来源应该位于同一域名下。

## SSRF Server Side Request Forgery

通过向易受攻击的服务器发送请求，从而访问重要的服务器，实现攻击。进入内网。

## SQL injection

## File Upload

## HTTP

长连接可以避免缓慢的连接建立过程，避免慢启动过程，加快了传输。降低了时延和连接建立的开销，将连接保持在已调谐状态，而且减少了打开连接的潜在数量。管理持久连接时要特别小心，不然就会累积出大量的空闲 TCP 连接，耗费本地以及远程客户端和服务器上的资源。
