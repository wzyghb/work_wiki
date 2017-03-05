
## XSS Cross-Site Script
### 定义
攻击者将客户端的脚本注入到网页中，使得其在其他用户客户端也会生效。
### 后续
这可能会导致用户的 cookie、授权信息、密钥等泄露。
### 防止
1. 对用户的输入进行 escape。（各个阶段均可、如存储之前，或者展示给其他用户之前）
2. 将 Cookie 设置为 `http-only`
3. Content-Security-Policy

## CSRF Cross-site Request Forgery
使得用户向被攻击网站发送一个攻击者希望的请求，而用户自己不知道。

### 防止
+ 只是用 JSON APIs
+ 禁用 CORS
+ `GET` 不应该有副作用
+ CSRF Token
  - 服务端会向客户端发送一个 token，仅附注在表单中
  - 客户端每次提交 form 时，也会发送 token
  - 服务端会对 token 进行检查
  - 只有通过表单正常访问敏感地址才会发送 token
+ Referer 字段：标明请求源于哪个地址，敏感数据的请求来源应该位于同一域名下。

## SSRF Server Side Request Forgery
通过向易受攻击的服务器发送请求，从而访问重要的服务器，实现攻击。进入内网。

## SQL injection

## File Upload
