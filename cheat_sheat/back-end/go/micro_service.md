# rpc

1. `runtime.GOMAXPROCS` 设置最大的可用 CPU
1. 使用 `flag` 读取配置参数
1. 从 `configfile` 读取配置文件

在 docker 中需要设定的环境变量

+ 服务的统一标识名称
+ 服务的分配端口号
+ 服务的内存、cpu 限制
+ 机房、集群设置
+ 地址

## 服务注册和发现

服务注册可以使用 python

+ [使用 docker](https://github.com/yeasy/docker-compose-files/blob/master/consul-discovery/docker-compose.yml)

## 统一RPC调用

## 服务调用跟踪

+ request_id

## 服务调用容灾

## 服务动态配置

## 定时任务

+ [chronos](https://mesos.github.io/chronos/)

## 接口示例 func in go

```go
type EndPoint func(ctx context.Context, req interface{}) (interface{}, error)

// Middleware deal with input EndPoint and output EndPoint
type Middleware func(EndPoint) EndPoint

// Chain connect middlewares into one middleware.
func Chain(outer Middleware, others ...Middleware) Middleware {
    return func(next EndPoint) EndPoint {
        for i := len(others) - 1; i >= 0; i-- {
            next = others[i](next)
        }
        return outer(next)
    }
}

func Build(mws []Middleware) Middleware {
    if len(mws) == 0 {
        return emptyMiddleware
    }
    return func(next EndPoint) EndPoint {
        return mws[0](Build(mws[1:])(next))
    }
}

func emptyMiddleware(next EndPoint) EndPoint {
    return next
}

type KiteBase interface {
    GetLogID() string   // 日志 id，用于垂直查错
    GetCaller() string  // 调用者
    GetAddr() string    // 获得调用地址
    GetClient() string  // 获得 client 类型
}
```

## 熔断
