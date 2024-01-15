# homer

[homer](https://github.com/sipcapture/homer/wiki/Quick-Install#-capture-agents) 是个抓 SIP 的工具。

组成组件：

- heplify: Go 写的 agent 端，负责从某指定机器上收集包并推送到服务端（另外还有其他语言的 agent）
- heplify-server: 服务端，负责收集客户端传来的 SIP 包，并进行整合等
- homer-app: 管理端，可以用来生成/读取 DB 配置表、DB 数据表等

可以和这些进行集成：

- [Freeswitch](https://github.com/sipcapture/homer/wiki/Examples%3A-FreeSwitch)
- Grafana
- sngrep
- RTPEngine
- RTPProxy
- Kamailio

## heplify-server

## Homer API

- https://github.com/sipcapture/homer/wiki/Using-Homer-API
- [v5 Doc](https://github.com/sipcapture/homer-api/blob/master/apidoc/doc.php)

## 线上情况

See [./homer.drawio](./homer.drawio)

数据库使用的是 postgres

```sh
# 在 docker 内连接 DB （psql postgres://username:password@host:port/dbname）
psql postgres://root:@localhost:5432
```

```sql
\l          -- list DB
\c DB_NAME  -- 连接到 DB
\d          -- list tables
\d TABLE_NAME -- 查看表结构信息
            -- 其他语法和 MySQL 类似

-- 查询某数据库大小
select pg_size_pretty(pg_database_size('DB_NAME')) as size;
--查询所有数据库大小
select datname, pg_size_pretty(pg_database_size(datname)) as size from pg_database;
-- 查看某表大小
select pg_size_pretty(pg_relation_size('TABLE_NAME')) as size;
-- 查看所有表大小
select relname, pg_size_pretty(pg_relation_size(relid)) as size from pg_stat_user_tables;
-- 按大小排序表
SELECT table_name, pg_size_pretty(pg_total_relation_size(table_name)) AS table_size
    FROM information_schema.tables
    WHERE table_schema = 'public'
    ORDER BY pg_total_relation_size(table_name) DESC;
```

当前 homer 数据表的大小如下（>1MB 以上的）：

```sh
               table_name               | table_size
----------------------------------------+------------
 hep_proto_1_registration_20240105_0400 | 40 GB
 hep_proto_1_registration_20240105_0200 | 40 GB
 hep_proto_1_registration_20240105_0600 | 40 GB
 hep_proto_1_registration_20240105_0000 | 39 GB
 hep_proto_1_registration_20240105_0800 | 27 GB
 hep_proto_1_call_20240105_0600         | 5041 MB
 hep_proto_1_call_20240105_0200         | 4727 MB
 hep_proto_1_call_20240105_0800         | 2954 MB
 hep_proto_1_call_20240105_0400         | 2835 MB
 hep_proto_1_call_20240105_0000         | 2724 MB
 hep_proto_5_default_20240105_0000      | 2273 MB
 hep_proto_5_default_20240105_0600      | 1564 MB
 hep_proto_1_default_20240105_0600      | 110 MB
 hep_proto_1_default_20240105_0400      | 106 MB
 hep_proto_1_default_20240105_0200      | 104 MB
 hep_proto_1_default_20240105_0000      | 75 MB
 hep_proto_1_default_20240105_0800      | 74 MB
```
