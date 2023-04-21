# WiredTiger 存储引擎

存储引擎的作用：

将磁盘上的数据读到内存，并返回给应用，或由应用修改的数据从内存写入到磁盘。

> 其他存储引擎简单知道下：
> - MMAPv1 在 4.2 弃用
> - In-Memory 内存数据库引擎、
> - WiredTiger、RocksDB 支持更细粒度锁，支持高并发查询
> - RocksDB 是由 Facebook 基于 LevelDB 开发的开源 KV 存储引擎


