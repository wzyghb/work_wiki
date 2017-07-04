
## Start
Consul 是使用 go 语言构建的 cluster 协同管理工具，其主要作用有：

+ Service Discovery
+ Health Checking
+ Key/Value Store
+ Multi Datacenter

## Architecture

+ 每个节点上运行一个 Consul agent。agent 主要用于检测node 上的 service 健康状况以及 node 本身的状态。
+ agent 和一个或者多个 Consul server 进行交互，Consul server 存储数据及其副本。副本数量的推荐值是 3-5。推荐每个 datacenter 有一个 cluster。
+ 你的 infrastructure 的任何组件如果需要发现其他的服务或者节点，只需要查询任意一个 Consul Servers 或者任意一个 Consul agents。
agent 会将对应的查询导向到 server 上去。
+ 每个 datacenter 运行一个 Consul servers 的 cluster。当一个 cross-datacenter service 发现或者配置请求发生时，局部的 Consul servers 会将其传递给远端的 datacenter 并返回一个结果。

## 和其他类似服务的对比
