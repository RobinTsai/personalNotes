## page eviction 页面淘汰

内存中“脏页”达到一定条件后，会触发淘汰。

- 淘汰触发条件：内存使用量达到一定比例、脏数据量达到内存一定比例
    - eviction_target，内存用量比例，默认 80%，触发后台线程淘汰（不会阻塞服务）
    - eviction_trigger，内存用量比例，默认 90%，应用线程参与淘汰（会阻塞服务）
    - eviction_dirty_target，脏数据占内存比例，默认 5%，触发后台线程淘汰（不会阻塞服务）
    - eviction_dirty_trigger，脏数据占内存比例，默认 10%，应用线程参与淘汰（会阻塞服务）
- 淘汰触发特殊条件：page 中内容占用内存大于系统设定的最大值（memory_page_max），强制进行 page eviction。
    > 1. 拆分大 page 为多个小 page
    > 2. 通过 reconcile 写入磁盘
    > 3. 上步完成后淘汰 page
- 算法：LRU 算法
- 线程：evict page 线程，有 work thread 和 application thread，前者时后台线程，后者是应用线程

> 淘汰前中先进行 page reconcile 将数据写入磁盘。

淘汰时：
- 会先锁住 page（WT_REF_LOCKED）
- 然后检查是否有读操作的 hazard 指针
- 若有，停止 evict，重置状态（WT_REF_MEM）
- 若无，淘汰