# htable

## 定义

语法：`htname=>size=_number_;autoexpire=_number_;dbtable=_string_`

```sh
# 案例
modparam("htable", "htable", "a=>size=4;autoexpire=7200;dbtable=htable_a;")
modparam("htable", "htable", "b=>size=5;")
modparam("htable", "htable", "c=>size=4;autoexpire=7200;initval=1;dmqreplicate=1;")

# 使用
$sht(HTNAME=>KEY)
```

- htname 哈希表的名称
- size 控制哈希表的桶数为 2^size，值范围 2-31，用链表解决哈希冲突。所以不会超限溢出。
- autoexpire 超时时间，如果为 0 则无超时时间
- dbtable 数据库表名，只在起始时 load 从数据库中读取
- cols 数据库表中的列名，需要用引号包裹并逗号分隔。使用时候可以用 `{s.select,...}` 选取对应的列
- dbmode 是否开启持久化（server stop 时是否写回数据库）
- initval 不存在时候的默认值，否则为 $null
- updateexpire 更新操作是否更新 expire 值
- dmqreplicate 开关，任何动作同步到其他节点（htable peers）。必须开启 `enable_dmq`

## x
