# 路由块

- [路由块](#路由块)
  - [request\_route](#request_route)
  - [route](#route)
  - [branch\_route](#branch_route)
  - [failure\_route](#failure_route)
  - [reply\_route: SIP 响应主路由块](#reply_route-sip-响应主路由块)
  - [onreply\_route](#onreply_route)
  - [onsend\_route](#onsend_route)
  - [event\_route](#event_route)

[Core Cookbook/Rouing Blocks](https://www.kamailio.org/wikidocs/cookbooks/4.4.x/core/#routing-blocks)

路由块是 Kamailio 执行路由表的方式。使用方法类似于 function。


```c
// 路由块定义的语法：
route_block_id[NAME] {
    ACTIONS
}
// 路由块的调用语法
request_route {
    // ...
    route("NAME")
    // ...
}
```

## request_route

- 每个 SIP 请求到来时执行。

## route

- 用于定义 子路由块；它还是一个函数，用于执行子路由块。
- 子路由块可以 return 一个 `integer` 值，用于控制路由流程。
- 父流程可以通过 `$rc` 获得子路由的返回值：负数表示为 false，0 表示 exit，正数表示 true。
- 子路由块嵌套次数受 `max_recursive_level` 控制以防无限循环。
- 子路由块的概念，允许将配置文件模块化。

## branch_route

- 请求的分支路由块。处理 SIP 请求的每一个 branch。
- 此块仅被 TM 模块 `t_on_branch("NAME")` 调用执行。

## failure_route

- 失败的事务（Transaction）路由块。处理所有 branch 收到 >= 300 的响应。
- 此块仅被 TM 模块 `t_on_failure("NAME")` 调用执行。
- 注意，此路由块只处理 初始化事务（transaction）的请求，不处理响应。

## reply_route: SIP 响应主路由块

- SIP 响应主路由块。它没有名称，SIP 响应会进入到此块处理。
- 这里没有能控制 SIP relay 的 network route，它是根据 Via Header 做的网络路由。因此没有必须用在此块的专门转发的动作。
- 可以使用 drop 函数丢弃 SIP 响应。

> 为了向后兼容，reply_route 也可以表示为 `onreply_route {...}` 或 `onreply_route["NAME"] {...}`

## onreply_route

- TM 模块执行的 SIP 回复路由块。必须通过 `t_on_reply("NAME")` 函数触发。

> 主 `onreply_route` 块可能在 TM 的 `onrelply_route` 之前执行。

## onsend_route

- 当 SIP 请求发出是执行此块。此块下仅一定数量的命令可用。
- 这些命令有：`drop`，`if (check) 语句`，msg flag 操作，`send()`，`log()`，`textops::search()`

## event_route

- 发生特定事件时执行的路由块。

- 原型：`event_route[groupid:eventid]`，greoupid 是触发事件的模块。
    - 如 `event_route[htable:mod-init]`，在所有模块初始化后由 htable 执行，如初始化静态值。
    - 如 `event_route[tm:local-request]`，在本地生成请求时执行。
    - 如 `event_route[tm:branch-failure]`，在所有响应失败时执行。
