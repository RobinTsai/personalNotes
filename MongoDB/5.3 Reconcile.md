## page reconcile 写入磁盘

在 page evict 之前，需要先将 page 写入磁盘。

> reconcile，使调和、使和谐一致，reconciled，reconciliation.

过程：
- （修改和插入会存在 WT_UPDATE 和 WT_INSERT_HEAD 两个数组中）
- 创建一个 page 大小的**缓存 buffer**，遍历上述两个数组，依次复制到 buffer 中并排序
- 多个 page。如有需要分配多个 page
- 先写入**磁盘映像 page**
- 再写入**磁盘 page**
    > 磁盘映像 page 是一个映射，对应到了 磁盘 page
    
reconcile 操作重点：将内存中修改的数据生成相应的**磁盘映像**，将映像写盘。


> 为什么需要个磁盘映像？
> 与磁盘中 page 格式匹配。是一一对应到 磁盘 page 的。