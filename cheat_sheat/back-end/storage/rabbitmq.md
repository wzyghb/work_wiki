# rabbitmq 简要总结

## 测试环境

使用 docker， [image 位置](https://hub.docker.com/_/rabbitmq/)

```yml
version: "2"
services:
 rabbitmq:
  image: rabbitmq:3-management
  volumes:
   - /etc/localtime:/etc/localtime:ro
  environment:
   RABBITMQ_DEFAULT_USER: lark_search
   RABBITMQ_DEFAULT_PASS: dev
  ports:
   - "5671:5671"
   - "5672:5672"
   - "15672:15672"
```

## frist blood

### port

+ 4369: for peer discovery service, used by RabbitMQ nodes and CLI tools
+ 5672: AMQP clients without TLS
+ 5671: AMQP client with TLS
+ 25673: Erlang distribution for inter-node and cli tools communitcation
+ 15672: HTTP API clients and rabbitmqadmin (only management plugin is enabled)

### Install

1. Erlang/OTP
1. Erlang Version Pinning  -> to avoid undesired erlang upgrades `/etc/apt/preferences.d/erlang`
1. Dependencies: erlang-nox, esl-erlang, init-system-helpers, socat
1. Config show chapter next

### Config

#### [Environment (Unix)](http://www.rabbitmq.com/configure.html)

rabbitmq 主要通过三种途径来进行配置：

1. Configuration file
1. Environment variables
1. Commonly configured core server settings

+ default location of `rabbitmq.config` and `rabbitmq-env.conf`: `/etc/rabbitmq/`
+ `rabbitmq-env.conf`
+ `rabbitmq.config`

+ 启动： `service rabbitmq-server start`
+ 停止： `rabbitmqctl stop`

> 通过 `rabbitmqctl environment` 来查看环境变量，但是感觉会过期

其他默认环境：

> rabbitmq home dir: `/var/lib/rabbitmq`

| name | location |
|:--- |:--- |
| `RABBITMQ_CONF_ENV_FILE` | 环境变量配置 |
| `RABBITMQ_CONFIG_FILE` | `/etc/rabbitmq/rabbitmq` |
| `RABBITMQ_MNESIA_BASE` | `/var/lib/rabbitmq/mnesia` |
| `RABBITMQ_MNESIA_DIR` | `$RABBITMQ_MNESIA_BASE/$RABBITMQ_NODENAME` |
| `RABBITMQ_LOG_BASE` | `/var/log/rabbitmq` |
| `RABBITMQ_LOGS` | `$RABBITMQ_LOG_BASE/$RABBITMQ_NODENAME.log` |
| `RABBITMQ_SASL_LOGS` | `$RABBITMQ_LOG_BASE/$RABBITMQ_NODENAME-sasl.log` |
| `RABBITMQ_PLUGINS_DIR` | `/usr/lib/rabbitmq/plugins:$RABBITMQ_HOME/plugins` |
| `RABBITMQ_PID_FILE` | `$RABBITMQ_MNESIA_DIR.pid` |

### Persistent

+ queue_index: maintaining knowledge about where a given message is in a queue, along with whether it has been delivered and acknowledged, one queue one index
+ The message store is a key-value store for messages, shared among all queues in the server. There are technically two message stores (one for transient and one for persistent messages) but they are usually considered together as "the message store".

## Concept

+ `Credential`
  + PlainCredentials
  + ExternalCredentials
+ **`Connection`**
+ **`Channel`**
+ Authentication 认证，这个用户究竟是谁
+ Authorisation 授权，这个用户有哪些权利
+ **`Virtual Hosts`**
+ **`exchange`**
+ **`routing`**
+ **`delivery mode`** 1 （not persist)

### Virtual Host

多租户系统 (Multi-tenant system): Connections, exchanges, queues, bindings, user permissions, policies, logical groups of entities.

+ rabbitmq 中，我们使用 `rabbitmqctl` 或者 http api 来创建 virtual hosts，而不是配置文件。
+ virtual hosts 提供了逻辑群组和资源的分离，物理上则取决于具体的实现细节。
+ 当一个 AMQP Client 连接到 Rabbitmq 时，他会被给到一个 vhost。 如果身份得到了验证，而且这个用户名提供了这个 vhost 的权限，那么连接就会建立。

### 权限控制

#### Authentication

rabbitmq 自己支持了三种形式的认证方式，还可以通过插件支持更多的认证方式。

+ PLAIN
+ AMQPLAIN
+ EXTERNAL
+ RABBIT-CR-DEMO 目前在 rabbitmq 中不完全支持

在 Server 端，在 configration file 中有 `auth_mechanisms` 来指定认证的形式。

#### Authorisation

rabbitmqctl 中提供了 `add_user` 和 `delete_user`

rabbitmq 中关于 Authorisation 是基于 Virtual host 的，rabbitmq 将权限分为 configure、write 和 read，而 exchange 和 queue 都包含在特定的 virtual host 中，在不同的 virtual host 中，相同的 queue、exchange 名字表示不同的 resource。

+ The configure operations create or destroy resources, or alter their behaviour.
+ The write operations inject messages into a resource.
+ The read operations retrieve messages from a resource.

## example code

### 1 接收请求

```python
import pika

credentials = pika.PlainCredentials("lark_search", "dev")
parameters = pika.ConnectionParameters(host="rabbitmq", credentials=credentials)
conn = pika.BlockingConnection(parameters=parameters)
channel = conn.channel()

channel.queue_declare(queue="hello", durable=True, exclusive=False, auto_delete=False)

channel.confirm_delivery()

def callback(ch, method, properties, body):
    print("ch: {}, ,method: {}, properties: {}, boxy: {}".format(ch, method, properties, body))

channel.basic_consume(callback,
                      queue='hello',
                      no_ack=True)

channel.start_consuming()
channel.close()
```

### 2 发送请求

```python
import pika
credentials = pika.PlainCredentials("lark_search", "dev")
parameters = pika.ConnectionParameters(host="rabbitmq", credentials=credentials)
conn = pika.BlockingConnection(parameters=parameters)
channel = conn.channel()

channel.queue_declare(queue="hello")
channel.basic_publish(exchange='', routing_key="hello", body="just for a test")

```

## Some problem

### Heartbeat

+ rabbitmq 的 connection 参数中有 `heartbeat_interval` 相关的参数，单位是 Seconds，server 端也会有一个 Heartbeat 的对应设置，最终的 heartbeat_interval 可以认为两者中较小的那个值。
+ rabbitmq 的这个值通常是 60 (3.5.5 中是 580)
+ Heartbeat frames 会在每 timeout/2 时间段内发送一次，当有两个 heartbeat 发送失败后，peer 将会被认为是不可达的，TCP 连接将会终止，当 RabbitMQ node 通过 heartbeat 认为 client 不可达时，需要重新连接。

> 为何需要 Heartbeat: 操作系统会将 idle 的 TCP 连接停止掉（如在 linux 中，这个值是 11 分钟）

### AMQP 协议

[AMQP](https://www.rabbitmq.com/amqp-0-9-1-reference.html)
