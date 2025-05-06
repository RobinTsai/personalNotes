# Undo 日志

原子性保证：要么全做，要么全不做。rollback 时要做回滚。

- 行记录中 roll_pointer 指针指向的就是本条记录的 undo 日志。
- 事务一旦提交，undo 日志就没用了。

> undo log 是怎么串联起来的？
>
> 一条记录（假设为 B 状态）的 roll_pointer 指针指向本记录从前一条数据（A 状态）变成现在样子的 undo 日志（A->B undo log），所以此指针找到 undo 日志后可以恢复到旧记录（A 状态）。
> 当本条数据再次变更为 C 状态时，会生成新 undo 日志（B->C undo log），此时会将 B 状态上的 roll_pointer 移动到 undo 日志的 roll_pointer 上，然后 C 状态数据的 roll_pointer 指向 B->C undo log。
> 由此，形成了以本条数据为头节点 undo log 为链表节点的链表。

## 聚簇索引下的增删改操作

### Insert 操作

插入操作的 undo 日志只需要记录此记录的 主键信息 就好。等回退时直接删除。

需要注意的有这几点：
- undo no 在一个事务中从 0 开始，每增加一条 undo log，自增 1
- 只记录主键信息：存储空间+真实值（主键可以有多个）
- 只针对于聚簇索引进行记录就好了，因为和二级索引记录是对应的
- 在事务提交时直接删除 undo 日志

日志类型：TRX_UNDO_INSERT_REC

### Delete 操作

数据页中存在两个链表：

- 正常记录通过 next_record 构成一个正常记录链表；
- 被删除的记录也会通过 next_record 字段形成垃圾链表。Page Header 中的 PAGE_FREE 字段指向了垃圾链表的头节点。

之前有讲过，删除过程是逻辑删，在删除过程中有两个阶段：

- 1. 将 deleted_flag 设置为 1，即标记为已删除
  - > 这里只是标记删除，但数据在链表中没有移动，事务提交前一直是这种状态。
- 2. 事务提交，将其从正常记录链表中移除，加入到垃圾链表中（真正地删除）。
  - > 真正删除后，还需要更新 page 中的一些信息，这里就忽略了。

因为一旦提交事务，就不需要回滚此记录，undo 日志也就没用了，所以 undo log 只记录阶段 1 的操作：生成一条 delete mark 的 undo log，将旧记录中的 roll_pointer 移动到 undo log 的 roll_pointer 中。

> 实际这个“delete mark 的 undo log”记录了很多东西。略了。

日志类型：TRX_UNDO_DEL_MARK_REC

### Update 操作

Update 要分情况讨论：

- 在不更新主键且为 **就地更新** 时
- 在不更新主键但为 **先删后插** 时
- 在 **更新主键** 时

> 需要强调一下，在更新操作中：
> - 就地更新：如果更新前后所有列占用空间均不变，则为就地更新；
> - 先删后插的更新：任何列的占用空间变大或变小，都会发生先删除后插入的更新操作。
> - 删除操作：删除操作会先置 deleted_flag，然后移动到垃圾链表中（彻底删除）。
> - 插入操作：插入操作会创建一个新的记录并插入到页面中，这可能会进行页分裂。

前两者用了一种 undo log 类型：TRX_UNDO_UPD_EXIST_REC，有点复杂先不展开记录了。

最后一种情况——更新主键时，使用先 delete mark，再创建一条新记录并插入的操作（注意，这里和上方的先彻底删不同）。对应地，在 undo 日志中记录两条日志分别是：TRX_UNDO_DEL_MARK_REC 和 TRX_UNDO_INSERT_MARK。

日志类型：
- 不更新主键时：TRX_UNDO_UPD_EXIST_REC
- 更新主键时：TRX_UNDO_DEL_MARK_REC + TRX_UNDO_INSERT_MARK （相当于 Delete 操作和 Insert 操作）

## 二级索引下的增删改操作

对于二级索引记录来说，INSERT 和 DELETE 操作与在上文的聚簇索引中执行产生的影响差不多，只是 UPDATE 操作有些不同。

当涉及到更新二级索引的索引列时，会产生对二级索引的 delete mark 操作 + insert 操作。

## Undo 页面链表

- 一个事务可能产生很多 undo 日志，一个页面放不下，从而形成页面链表；
- undo 页面链表分两种：insert undo 页面链表和 update undo 页面链表；
- 对于普通表和临时表的 undo 日志要分别记录；
- 由上 2、3，一个事务最多有四个 undo 页面链表；
- 不同事务的 undo log 放到不同的 undo 页面链表；
- 所有的 Undo 页都是从 Undo Log Segmeng 中申请的；
- undo 日志在 undo 页中是紧密排列的，undo 页面是形成链表的；
- 一个 undo 页面链表形成一组 undo 日志；但还有重用的情况，导致页面链表被多个事务公用了。
- 一个 undo 页面链表对应一个段（一个段对应一个页面链表）；
- 链表的基节点放在段中首个页的 段Header 中

## undo 页面重用

条件：

- 链表中只有一个页
- 页面使用空间不多于 3/4

重用：

- 对于 insert 链表，可以直接覆盖（因为事务提交后就没用了）
- 对于 update 链表，按组存入后方（每组 undo 日志会有 undo log Header，记录信息）

## 回滚段

- 一个 Rollback Segment Header 对应一个回滚段；
- 回滚段中存放许多 undo slot
- 每一个 undo slot 对应一个 undo 页面链表的头节点

系统一个 128 个回滚段，每个回滚段可支持 1024 个 undo slot，所以系统共支持 128 * 1024 个回滚页面链表。

## undo 日志与崩溃恢复

在服务器崩溃恢复中，会先安装 redo 日志将各个页面恢复到崩溃前的状态。

这里，一些没提交的事务也会恢复到磁盘上了。

这是就用到 undo 日志进行回滚处理了：

1. 遍历回滚段
2. 遍历回滚段中的 undo slot（非空对应一个 undo 页面链表）
3. 从页面链表的 UNDO LOG FREGMENT HEADER 中找到 TRX_UNDO_ACTIE（活跃状态的事务）的 TRX_UNDO_STATE 属性
4. 从 UNDO LOG HEADER 中找到对应 事务 ID 并开始回滚
