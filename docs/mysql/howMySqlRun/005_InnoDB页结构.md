# 页结构

- InnoDB 用 ***页* 作为磁盘和内存之间交互的基本单位**，页大小 16K。
- 即，一次从磁盘读取到内存，最少 16KB；内存刷回磁盘，最少 16KB。

页有好多类型的，这里只说索引页。

![page](/assets/mysql_page.png)

## 页的结构

- File Header：文件头，存储页的信息，和前后页形成双向链表
- Page Header：页头，记录页内的存储信息，槽数量、最后插入位置、当前页位于 B+ 树的层级等等
- Infimum 和 Supremum：页中最小、最大记录
- User Records：存储行记录的地方
- Free Space：空闲空间
- Page Directory：页目录，记录槽（组）的偏移量等信息
- File Trailer：文件尾部，用于校验完整性，FileHeader 中也有相同的值，这样来判断刷盘的完整性

## 总结

- 页与页之间形成双向链表（File Header）
- 页内数据形成单向列表（User Records 的 next_record）
- 页内又分组，将组内最大记录的位置记在槽上，槽在页目录中，加速查询
- 记录的单向列表头为 Infimum 尾为 Supremum
- 页头、页尾有相同的校验和，这样是为了检验刷盘后的完整性
