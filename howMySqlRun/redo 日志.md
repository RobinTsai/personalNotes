# redo 日志

为何用，通过 Buffer Pool 的 flush 链表刷盘（刷脏）：
- 一次修改一点也要刷一页的数据，太浪费（每次刷盘是以页为单位的）
- 随机 IO 慢，尤其是机械硬盘

由上，需要一种机制，保证**快速高效**地刷盘且保证持久性。mysql 依然使用 flush 链表进行刷盘，不过这里刷盘并不保证持久性；而是使用了 redo 日志保证持久性。

即，当提交事务后，先写 redo 日志，然后修改 flush 链表，之后在某个时机将 flush 链表同步到磁盘中。

> 通常的做法是 **先写日志机制（WAL，write ahead log）**，这里 redo log 就是。
> redo 日志保证持久性，undo 日志保证原子性。

优点：
- 占用空间非常小
- 顺序 IO，顺序写入磁盘

## redo 日志格式和文件格式

> 这里的 redo log 说的是日志数据，提到文件说的是 redo log 落盘的文件，注意区分。

**redo log 数据**：其中记录了类型、表ID、页号以及数据信息（展开说太复杂了，知道这个就好）。type 类型定义了多种格式，不同类型对应的记录格式不一样。

**redo log 组**：mysql 中一个 MTR （Mini-transaction，一个事务单元、一个原子操作）对应一组 redo 日志，刷盘或恢复时同样是按组进行的。 

**redo 日志缓冲区**（log buffer）：log buffer 是连续的内存空间，被划分为若干个 512K 大小的 block，每个 block 记录了多条 redo log，每次刷盘按 block 为单位进行刷盘（log buffer 的 block 是日志文件 block 的镜像）。

**redo 日志文件**：每个 redo 日志文件格式都一样，前 4 个 block 用来存储一些管理信息，后面则是 redo log 数据信息。前 4 个block 依次是 log file header、checkpoint1、无用块、checkpoint2。

需要注意的是**仅第一个文件的 checkpointN 是有用的**。他们记录了 checkpoint 信息，在恢复流程中会用到。

> 使用 `SHOW VARIABLES LIKE 'datadir'` 查看存放目录，默认名为 `ib_logfile0`, `ib_logfile1` 文件。

## 工作方式

分两步来介绍：

- redo 日志写入到缓冲区
- redo 日志缓冲区刷盘

### 写入到缓冲区

- 当执行命令时，同步收集 redo 日志（成组记录）
- 当事务提交时，将记录成组复制到 **redo 日志缓冲区**中（log buffer，顺序的内存）
- 写入到 redo 日志后，增长 lsn（按字节数增长）

### redo 日志刷盘时机

- log buffer 空间不足时
- 事务提交时
- 某个脏页刷盘前，要将此脏页前方和自己的所有 redo 日志刷盘
- 后台线程，每秒一次将 log buffer 刷盘
- 正常关闭服务器时
- 做 checkpoint 时（后面讲）

### 刷盘过程

刷盘过程是 log buffer 和 磁盘文件的协作，程序需要知道从哪里开始刷盘。

四个全局变量（前两个是记录，后两个是地址）：

- `lsn`，用来记录当前写入 log buffer 的 redo log 的日志量。
- `flushed_to_disk_lsn`，表示已经同步到磁盘的 redo log 的日志量。
- `buf_free`，当前写到 log buffer 空间的地址。
- `buf_next_to_write`，当前写到磁盘的 log buffer 空间的地址。

> lsn，log sequence number。
> log buffer 中 `lsn` 的下一条地址就是 `buf_free`，`flushed_to_disk_lsn` 的位置就是 `buf_next_to_write`

刷盘过程就是从 `buf_next_to_write` 处开始刷盘，刷了多少字节记录到 `flushed_to_disk_lsn` 中。


（`lsn` 和 `buf_free` 是在 写入 log buffer 缓冲区的时候增长）

## redo 日志与 flush 链表

flush 链表中每个节点中存放了两个 lsn 记录：

- `oldest_moidfication`，记录第一次写此页的 lsn 值
- `newest_modification`，记录最后一次写此页的 lsn 值

并且 flush 链表是按 **第一次修改时间** （`oldest_modification`）**逆序**排序的。

这两个值和排序信息在用 redo 日志恢复数据时很重要！

## checkpoint

checkpoint 操作是 **检查 redo log 记录的数据中，哪个点之前的数据已经完全同步到磁盘中了**。那么这个点之前的数据就可以被覆盖，进而重用 redo log 文件。

> 注意，是数据同步到磁盘，而不是 redo log 同步到磁盘。

实现原理：

用户数据页是通过 flush 链表同步到磁盘的，flush 链表是通过 `oldest_modification` 记录的 lsn 值逆序排列的，所以我们可以知道：**只要小于 flush 链表最后节点的 `oldest_modification` 的 lsn 值，肯定是已经同步到磁盘了。**

所以 **checkpoint 操作就是将 flush 链表最后一个节点的 `oldest_modification` 值信息刷到文件中。**

checkpoint 过程中有三个关键值会写入 redo log 日志文件中：

- checkpoint_no，记录做 checkpoint 的次数
- checkpoint_lsn，记录做 checkpoint 时 flush 链最后一个节点的`oldest_modification` 值（即可被覆盖的最大 lsn）
- checkpoint_offset，记录 checkpoint_lsn 在文件中的偏移量

> 注意：可见，checkpoint 操作有写磁盘操作，比较消耗性能，所以并不是每次将脏页刷入磁盘都做 checkpoint。

上述三个关键值会写入到 ib_logfile0 （**注意：是第一个文件**）中前 4 个 block 中的 checkpoint1 或 checkpoint2 中。

> 为什么要设计有两个 checkpoint？两个checkpoint 该选那个进行存储呢？
> 因为……
> 规定：checkpoint_no 当为偶数时，存入 checkpoint1，为奇数时存入 checkpoint2。

> 注意：checkpoint_lsn 前的数据肯定是已经同步到磁盘了；但由于它执行的滞后，之后的数据可能被存盘也可能没有。但不影响下面的恢复。

## 崩溃恢复

redo 日志只用在 崩溃恢复，不用在正常运行过程中用户数据同步到磁盘的操作。所以如果 redo 日志中记录的数据已经刷盘，这些数据就完全没用了。

恢复过程：

- 确定恢复的起点
    - 在第一个日志文件前 4 个 block 中对比两个 checkpoint 内 checkpoint_no，哪个大用哪个
    - 从 checkpoint 信息中获取到 checkpoint_lsn 和 checkpoint_offset
- 确定恢复的终点
    - 从起点向后遍历直到第一个 block length 不满 512K 位置（判断是 O(1)的，因为有记录）
- 按修改的页位置进行分组
    - 跳过已经刷新到磁盘的 log。（**利用页中存储的 `newest_modification`**）
    - 扫描 redo log 构建按 **表ID 和 页ID 的哈希值** 作为 key 的哈希表，value 是 **此缓存页对应的 redo 日志组成的链表**
- 对哈希表中每个元素（页）进行恢复

注意细节中解决了一些问题：
- redo 日志恢复要保证顺序恢复：链表是按 redo log 的顺序构建的
- 恢复时刷盘是按页进行的，高效：哈希表的意义
- 通过 `newest_modification` 会跳过已经刷盘的 redo log：不会重复操作

> 再解读一下“跳过已经刷新到磁盘的 log”的过程，有点绕
> 
> 因为 flush 链表是按 `oldest_modification`（简称 `o_m`） 降序排序的（第一次修改插到头部）。
> 如果 flush 链表在 checkpoint 之后刷盘，那在磁盘上存放的此页信息`n_m`、`o_m`，且一定存在关系：`n_m >= o_m > c_l`。
> 所以磁盘上页记录的区间 `[o_m, n_m]` 表示此区间内的 lsn 记录都已经刷盘了。
> 即：要恢复此页的数据只需要恢复 lsn > n_m 的写操作就好了。 