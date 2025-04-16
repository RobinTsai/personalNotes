# 复制集 Oplog
 
数据同步机制（一致性保证）：
- Secondary 异步复制 Primary 的 Oplog 日志
- Secondary 提取 Oplog 日志并执行

Oplog 基础信息：
- 存在 `local` 库的 `oplog.rs` 表中（在数据库中存是最方便的）
- 表 `oplog.rs` 是固定大小的集合
- 默认 空闲磁盘空间*5%，但同时最小 990M，最大 50G
- `rs.printReplicationInfo()` 可查看 oplog 信息

磁盘占用不大但 Oplog 增长大的三个场景：
- update 操作为每个文档一条记录
- 先插入再删除操作
- 大量 In-Place 修改操作

配置 Oplog 大小：
- 原因：太小导致频繁全量同步
- 查询命令：`use local`; `db.oplog.rs.stats().maxSize`
- 修改命令：`use admin`; `db.adminCommand({replSetResizeOplog:1, size: 1000})`
- 流程问题
    - 先 Secondary 配置
    - 再 Primary 配置

全量同步（initial sync）方法：
- 自动方式：
    - 手动清空 DB 数据目录
    - 重启 Mongod 进程
    - MongoDB 会自动执行 initial sync
- 手动方式（更快完成同步）：
    - 手动清空 DB 数据目录
    - 从源节点将数据目录打包、复制、解压到目的节点目录
    - 启动 Mongod 进行

> 终止 Mongod 进程需要切换到 admin 库下，用 `db.shutdownServer()` 命令