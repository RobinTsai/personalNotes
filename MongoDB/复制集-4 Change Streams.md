# 复制集-Change Streams

节点之间通过 Oplog 实现数据同步有延迟。

Change Streams 功能：
- 3.6 版本提供
- 允许用户将实时变更的数据流同步到下游系统
- 解决 oplog 日志延时的问题

实现：
- 客户端应用中，开启 数据库 或 集合 的监听（watch，返回 corsor）
- 捕获变更事件，获取变更数据流（）
- 将变更数据流发送到下游系统进一步处理

数据流信息：
- ns，操作的 db、collection
- 完整文档（可选）
- 变更后的 ns （如 rename 操作）