# RDB

手动触发命令

- save：阻塞服务进程
- bgsave：通过 fork 创建子进程，只在 fork 阶段阻塞

自动触发

- 配置 `SAVE m n`，在 m 秒内存在 n 次操作后直接触发
- 从节点执行全量复制，主节点自动执行 bgsave
- 执行 debug reload 重新加载时，自动触发 save
- shutdown 命令下若无 AOF 时，自动 bgsave

## BGSAVE 流程

- 执行 bgsave
- 父进程先判断是否已经存在运行中的子进程
- fork 操作，fork 期间会阻塞
- 子进程落盘 RDB，成功后原子替换旧的
- 发送信号给主进程表示完成

## RDB 优缺点

优点：

- 紧凑 压缩 二进制 文件
- 全量备份
- 恢复数据快（远远快于 AOF）

缺点：

- 不够实时
- 重量级，有 fork 操作，成本较高
- 兼容性问题。在 Redis 演进过程中有多种格式版本