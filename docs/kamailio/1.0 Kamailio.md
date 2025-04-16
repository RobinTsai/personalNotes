# Kamailio 和 SIP

## Kamailio

Kamailio 是一个开源 SIP 服务器，主要用作 SIP 代理服务器、注册服务器等，而 FreeSWITCH 是一个典型的 SIP B2BUA，主要用作 VoIP 媒体处理。

Kamailio 主要处理 SIP 协议，可以支持每秒成千上万次（为什么不给出一个具体的数量级？）的建立和释放（Call Attempt Per Second，CAPS）。

Kamailio 和 FreeSWITCH 配合最常见场景是 K 作为注册服务器和呼叫负载均衡服务器，而 FS 进行媒体相关处理（转码、放音、录音、呼叫排队等）。

K 是一个：

- SIP 服务器
- SIP 代理服务器
- SIP 注册服务器
- SIP 地址查询服务器
- SIP 应用服务器
- SIP 负载均衡服务器
- SIP WebSocket 服务器
- SIP SBC 服务器

K 不是一个：

- SIP 软电话（不可以发起/接听电话）
- 媒体服务器（不可以做音视频媒体处理）
- 背靠背用户代理（B2BUA）

### 基本架构

和 FreeSWITCH 一样，由核心和可加载模块组成。核心只负责基本 SIP 消息处理。

配置文件（默认）：kamailio.cfg

配置文件的语法：类似于 C 语言，更像是个脚本

配置文件组成部分：
- 全局参数：如日志、调试级别（dbg）、IP/PORT 等
- 模块，使用 `loadmodule()` 指令加载模块
- 主路由块，是 `request_route` 块，是最先接触 SIP 的地方；`reply_route` 块，是负责处理 reply 主路由块。
- 次级路由块，是 `route[PARAM]` 定义的块，在主路由块中用 `route(PARAM)` 调用使用此块
- 回复路由块，是 `onreply_route[PARAM]` 定义的块，用于处理响应的 SIP 消息（如 200 OK）
- 失败路由块，是 `failure_route[PARAM]` 用于处理失败，如忙、超时等
- 分支路由块，是 `branch_route[PARAM]` 定义的块，在对 SIP 进行 Fork 操作时，处理每个分支的逻辑
- 本地路由块，用于在 K 作为 UAS 时产生一条通过 TM 模块主动发送的消息

[路由块](https://www.kamailio.org/wiki/cookbooks/5.4.x/core#routing_blocks)
