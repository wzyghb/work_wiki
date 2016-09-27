
## 1 介绍

+ 需要维护大量的状态，状态会不断地变化，带来大量的问题。

### redux 三大原则

1. 单一的数据源 整个应用的 state 被存储在一颗 object tree 中，并且这个 object tree 只存在于唯一的一个 store 中。开发中可以将这个单一的state
保存在本地。
2. state 是只读的，唯一改变 state 的办法就是触发 action，action 是一个用于描述已经发生事件的普通对象。
确保视图和网络请求都不能直接修改 state，相反它们只能表达想要修改的意图。所有的修改都会被集中化处理，并且严格按照一个接一个的顺序执行，因此不再用担心 race】
 condition 的情况出现。Action 就是普通对象而已，因此它们可以被日志打印、序列化、存储、后期调试或者测试时回放出来。
3. 使用纯函数来执行修改 为了描述如何使用 action 改变 state tree，需要编写 reducers。
reducers 只是一些纯函数，接收 先前的 state 和 action，并且返回新的 state。刚开始你可以只有一个 reducer，随着应用的变大，你可以将其拆分为多个 reducers。
分别独立地操作 state tree 的不同部分，因为 reducer 知识函数，可以控制其调用的顺序，传入附加的数据，甚至编写可复用的 reducer 来处理一些通用的任务，如分页器。

模型的更新集中到 reducer 层。不允许程序直接修改数据。集中到 action 的普通对象中进行更改描述。 (state, action) => state





