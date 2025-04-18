# sqlite

```sh
apt install -y sqlite3

sqlite3 /usr/local/freeswitch/db/core.db # sqlite 每个 .db 文件是个 DB，直接这样连接
```

```sql
-- 注意：点命令无分号，查询命令有分号
.help -- 查看点命令，点命令是一些表的查询项和设置项

.databases           -- DB 列表
.tables              -- 表列表
.schema table_name   -- 查看表结构

.show        -- 查看一些设置
.header on   -- 打开 header 展示
.mode column -- 栏模式（展示模式） line：每字段一行
.timer on    -- 打开 CPU 消耗时长统计

-- 查询命令
SELECT * FROM table_name;                                          -- 执行查询
INSERT INTO table_name (column1, column2) VALUES (value1, value2); -- 插入数据
UPDATE table_name SET column1 = new_value WHERE condition;         -- 更新数据
DELETE FROM table_name WHERE condition;                            -- 删除数据
```
