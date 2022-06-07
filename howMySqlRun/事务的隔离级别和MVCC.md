# 事务的隔离级别和 MVCC

## 事务中的一致性问题

（理论基础）

- 脏写，一个事务修改了另一个未提交事务中已修改的数据（一定不能有）
- 脏读，一个事务读到另一个事务修改的中间数据（如修改又回滚的中间数据）
- 不可重复读，一个事务两次读取的数据不一样（读到另一个未提交事务中的修改的数据）
- 幻读，一个事务中两次查询列表的结果不一样

严重性排序：脏写 > 脏读 > 不可重复读 > 幻读

> mysql 使用互斥锁来保证一定不会出现脏写。

## SQL标准四种隔离级别

（理论基础）

- Read Uncommitted：读未提交
- Read Committed：读已提交，解决了脏读
- Repeatable Read：可重复读，解决脏读、不可重复读
- Serializable：可串行化，解决所有

> 脏写 是一定不会发生的。

mysql 有这四种隔离级别，其他 SQL 对这四种隔离级别的支持不一样。如 Oracle 就只支持 Read Committed 和 Serializable。且各标准级别下允许发生的现象也是有出入的——mysql在 Repeatable Read 下很大程度上页禁止了幻读。

## 隔离级别命令

```SQL
SET [GLOBAL|SESSION|] TRANSACTION ISOLATION LEVEL <level>

level: {
    Read Uncommitted
  | Read Committed
  | Repeatable Read
  | Serializable
}
```

scope：

- SESSION：当前 Session 下有效（如果在事务中执行，当前事务无效）
- GLOBAL：全局有效（如果在食物中执行，当前事务无效)
- 空：仅对下次事务有效

全局配置:

- `transaction-isolation`

## MVCC 原理

MVCC，Multi-Version Concurrency Control，多版本并发控制

聚簇索引记录中有以下关键信息:
- trx_id：最近一次改动此条聚簇索引的事务ID
- roll_pointer：指向修改前的记录（undo 日志链表）

在每次更新操作后，都会把旧值放到一个 undo 日志中，形成链表，这个链表被称为版本链。mysql 使用版本链控制并发事务访问相同记录的行为，这就是 MVCC。

在 读未提交 隔离级别下，不需要 MVCC 控制，直接读取记录最新版本就可以了。对于 串行化 隔离级别来说，使用了加锁的方式访问。所以用不到 MVCC。

### 一致性视图 ReadView

一致性视图是通过对**当前系统下**（注意点1）**所有活跃的事务状态**生成一次快照（一个视图），在版本链中判断当前隔离级别下哪些修改版本可用。

> 注意：是 **当前系统下** 所有活跃的事务，而不是针对于某记录，其实也没法针对于某记录创建视图。（？？？我就是想到这个点会不会有坑，引发了个思考，还不通）

过程中有如下关键信息：
- m_ids：生成 ReadView 时，**活跃的**事务 ID 列表
- min_trx_id：生成 ReadView 时，**活跃的**事务 ID 列表中最小的 ID
- max_trx_id：生成 ReadView 时，系统下一个应该分配的事务 ID
- create_trx_id：生成此 ReadView 的事务 ID

> 注意：max_trx_id 不是 *活跃的事务中最大的 ID*。（见下方自问自答）

有了这个视图之后可以很方便地找到当前事务的可见版本。

是否可见，比较记录中的 trx_id：
- `== create_trx_id`，为自己修改的版本肯定**可见**
- `< min_trx_id`，一定是已提交的版本，**可见**
- 在 `[min_trx_id, max_trx_id]` 之间，但不在 `m_ids` 列表中，是已提交的，**可见**
- `>= max_trx_id`，为生成本视图之后创建的事务修改的记录，**不可见**（注意点2）

有了以上可见性准则后，按以下准则可实现隔离级别下的可见性问题：
- **读已提交**：**每次** 读都生成一次 ReadView
- **可重复读**：只在 **第一次** 读的时候生成一次 ReadView

> 问：在版本链中，可以用 `create_trx_id` 的比较来判断可见性吗？
> 
> 答：不可以，因为修改版本的 trx_id 在链中可以是无序的，可能事务 99 在事务 100 前创建，但事务 100 先对某记录修改并提交（注意只有提交了才能被另一个写，不然就成了脏写或死锁了）。

> 问：`max_trx_id` 是否可以改成定义为 “活跃的最大的事务 ID” 的变量
> 
> 答：不可以，因为这样就无法识别处在创建视图之后创建的事务了，上面说了 `create_trx_id` 不适合用来判断可见性，如果在 Read Committed 下这种做法没问题，但在 Repeatable Read 下，视图只生成一次，你就没法判断记录中某大于 `max_trx_id` 是否是在创建视图前写入的还是创建视图后写入的。

> 注意：事务 ID 的分配时机
> 
> 一般情况下，事务 ID 在事务中第一个修改操作才会分配，分配前为 0。

> 注意：一致性视图的分配时机
> 
> 一般情况下如上所述，在查询的时候生成。但在 Repeatable Read 隔离级别下，可以通过命令在开启事务的时候就生成：`START TRANSACTION WITH CONSISTENT SNAPSHOT`

## 二级索引与MVCC

由于只有聚簇索引才有 trx_id 和 roll_pointer 隐藏列，那么在二计索引查询时，怎么判断可见性呢？

由于二级索引页中存了一个当前页中最大事务 ID 的属性 PAGE_MAX_TRX_ID，可以通过它进行初步的判断，如果此属性小于 `min_trx_id` 那么一定可见；否则再在回表后进行判断。

## undo 日志的 purge

MVCC 用了 undo 日志，所以在 undo 日志删除前要保证 MVCC 不再用才可以删，这个删除操作就被称为 purge。那么怎么删呢？

- insert 的 undo 日志在事务提交之后就可以删除

因为 insert 的 undo 日志不被用在 MVCC 中。（为什么呢？待补充）

purge 过程：

mysql 会把当前系统中的所有 ReadView 按创建时间连成一个链表，当执行 purge 时，将最早生成的 ReadView 取出来（如果没有 ReadView，就生成一个，那这个肯定事务 no 很大），然后找到各回滚段中事务 no 小于当前 事务 no 的 undo 日志，进行删除。