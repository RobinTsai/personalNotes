# Page 生命周期、状态和大小参数

生命周期

- 从磁盘读入内存
- 在内存中修改
- 如有更改进行 reconcile 写入磁盘，完成后淘汰
- 加入到淘汰队列，被 evict 线程淘汰
- evict 线程将没被修改的 page 直接丢弃

淘汰时（同样见 页面淘汰 一节）：
- 会先锁住 page（WT_REF_LOCKED）
- 然后检查是否有读操作的 hazard 指针
- 若有，停止 evict，重置状态（WT_REF_MEM）
- 若无，淘汰

状态：
- WT_REF_DISK：初始状态，在磁盘中，没被读到内存
- WT_REF_DELETED，此 page 已被删除（不再需要被读）
- WT_REF_LIMBO，已加载到内存，但 page 上还有额外的修改数据在 lookaside table 上
- WT_REF_LOOKASIDE，在磁盘中，但同时在 lookaside table 中也有相关的修改。再读时，需要 load 磁盘+lookaside table
- WT_REF_LOCKED，正在被 evict
- WT_REF_MEM，已被读到内存，可正常访问
- WT_REF_READING，正在从磁盘读到内存（防线程并发读）
- WT_REF_SPLIT，切分成小块（原来的 page 将不再使用）

## page 大小参数控制