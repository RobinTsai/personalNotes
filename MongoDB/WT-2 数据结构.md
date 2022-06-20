## 数据结构

### 典型 B-Tree 结构

> 注意是典型的 B-Tree 不是 WiredTiger 的 B-Tree

- 根节点、内部节点、叶子节点（root page, internal page, leaf page）
- 每个节点是一个 page
- 数据以 page 为单位在内存和磁盘间进行调度
- page 的大小决定子节点（分支）的数量
- 每条索引记录包含一个数据指针，指向存在文件中的数据（偏移量）
- 根节点和内部节点**常驻**内存，所以查一条数据通常需要 2 次 IO（一次到叶子节点，一次到文件数据）

### 磁盘中的基础数据结构

- 索引文件
- 数据文件
- （看书理解是）索引的所有节点都是从 *索引文件* 中 load 进来的
- *索引文件* 的每条索引会包含一个 *数据指针*，指向数据文件中数据所在文件的偏移量

磁盘中数据结构：

- 也是个 B-Tree 结构
- 和 *索引文件* 不同的是：**数据文件** 对应的 B-Tree 的叶子节点上除了存储键名外，还会存储真正的集合数据
- 所以可以认为是 B+ 树

叶子节点：

- 包含 页头（page header）、块头（block header）、真正的数据（key/value）
- 页头：定义页的类型、实际载荷数据大小、记录条数 等信息
- 块头：定义页的 checksum、在磁盘上的寻址位置 等信息

WiredTiger 由一个块设备管理器模块，用于为 page 分配 block。

定位数据过程：
- 先通过 block 找到此 page（相对于文件起始的偏移量）
- 通过 page 找到行的相对位置
- 计算出 行数据 对应 文件起始位置 的偏移量（offset）

一个 offset 是 8 字节变量，所以磁盘文件最大 2^64 bit 大小。

### 内存中的基础数据结构

WiredTiger 会按需将磁盘中的数据以 page 为单位加载到内存，同时在内存中构造出响应的 B-Tree 来存储。

内存中的页

- 根页、内部页、叶子页（root page, internal page, leaf page）
- 根页 和 内部页 包含指向 子页的 指针，不包含真正的数据
- 叶子页 包含真正的数据和指向父页的 home 指针

leaf page 内结构：

- WT_ROW 数组，保存从磁盘的 leaf page 中读取的 K/V （原始读取）
- WT_UPDATE 数组，每条元素保存被修改的记录，多次修改以链表形式存
- WT_INSERT_HEAD 数组，其元素上有一个 WT_UPDATE 属性，插入的数据在这里保存
- WT_INSERT_HEAD 数组会以跳表的形式构成，以提高插入效率

### page 的其他数据结构

- WT_PAGE_MODIFY：保存 page 上事务、脏数据字节大小等和 page 修改相关的信息
- read_gen：用于 LRU 队列的位置
- WT_PAGE_LOOKASIDE：在 reconcile 时，如果还有事务正在读此 page 修改的数据，则会保存在 lookaside table 中，再次读时，用 lookaside table 数据重建内存 page。
- WT_ADDR：reconcile 按照此地址将 page 刷盘
- checksum：page 的校验和

### 总结（按书中所说的理解）

- 在磁盘上存有索引文件和数据文件
- 索引文件会 load 到内存中，称为 B-Tree 形式存储
- 内存中的 B-Tree 的 根页 和 内部页 会常驻内存，但 叶子页 会按需 load
