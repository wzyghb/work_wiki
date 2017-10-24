# go web

## libs

+ [log](https://github.com/sirupsen/logrus)

## example code

```go
import (
    log "github.com/sirupsen/logrus"
)

// main 程序的作用
InitConfig()
InitLogger()
InitCache()
InitDB()
InitCassandra()

if IsOnline() {
    InitOnlineConfig()
}

go HeartBeat()
go Watch()
go SyncCanary()

err := ListenAndServe(config.address)

if err != nil {
    log.Fatal(err)
}
```

共享变量加锁：

```go
import (
    "sync"
)

mutex sync.Mutex

mutex.Lock()
defer mutex.Unlock()
// 修改数据
```

网络请求

```go
import (
    "net/http"
)
```

## tools

+ `gofmt -w .` 格式化当前代码 [gofmt](https://golang.org/cmd/gofmt/)
+ [go-torch](http://lihaoquan.me/2017/1/1/Profiling-and-Optimizing-Go-using-go-torch.html)
+ [go-wrk](https://github.com/adjust/go-wrk)

## Problem

+ heartbeat: 打点到 metrics
+ go 中也可以和 python 类似，在包中直接定义单例对象

## Test

### `ginkgo` and `gomega`

+ `ginkgo generate xxx`

+ `Describe`
+ `Context`
+ `Expect`
+ `It`
