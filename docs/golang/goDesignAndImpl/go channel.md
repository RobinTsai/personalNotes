# go channel

- 用 `for range CHANNLE` 的时候一定要注意关闭 CHANNEL，否则就要用其他机制来确保能退出，可以用 `for { select case1 CHANNEL, case2 TIMEOUT}` 来替代


## 实现

- 通道是用 **数组 + 链表** 实现
- **数组** 是用于实现缓冲空间的循环队列
- **链表** 是用来实现阻塞时协程的存放。

## select

- select 会对每一个通道加锁，加锁顺序是按地址顺序排序的，这样避免死锁问题

## 矢量时钟 happened-before

- 矢量时钟（Vector Clock）是用来观察事件之间的 hanppened-before 的
- 每个协程在创建时都会初始化矢量时钟，在读取或写入事件时会修改自己的逻辑时钟
