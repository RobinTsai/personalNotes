# KEMI

KEMI 是 Kamailio 编写配置文件（`kamailio.cfg`）使用的 DSL（Domain-specific Scripting Language，特定领域脚本语言）。

此配置文件主要包含四类声明：

- 全局参数
- 加载模块
- 模块参数
- 路由块（`request_route {...}`，`reply_route {...}`，`branch_route {...}` 等）

四类声明的执行阶段：

- 前三者及 *初始化事件路由* （`event_route[htable:mod-init] {...}`）在程序启动的时候就执行了
- 路由块是在运行状态下会执行多次
