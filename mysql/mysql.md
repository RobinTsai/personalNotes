## 命令

### 连接

```sh
mysql -hHOST -uUSERNAME -pPASSWORD DB_NAME                      # DB 名直接加即可
mysql -hHOST -uUSERNAME --password='WITH_SPECIAL_CHAR_PASSWORD' # 特殊符号的密码用参数名的全称，用单引号（双引号有时候不好）
mysql -hHOST -uUSERNAME -pPASSWORD DB_NAME -e 'MYSQL CMD'       # 执行命令用 -e
```

### 表管理

```sql
ALTER table tableName ADD INDEX indexName(columnName)
ALTER TABLE tableName ADD COLUMN column_name tinyint DEFAULT 0, ADD COLUMN column_name_2 tinyint DEFAULT 0;
ALTER TABLE tableName MODIFY COLUMN column_name TINYINT DEFAULT 0;

ALTER TABLE tableName CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE tableName CONVERT TO CHARACTER SET utf8mb4;

ALTER DATABASE db_name DEFAULT CHARACTER SET character_name
```

### 字符集

- DB 内表的字符集不同会导致无法关联查询（Error: 1267）（遇到的情况是：甚至从 A 表查出后字段赋值给 B 表一个字段用于查询）
- 字符集有 DB 的字符集、连接的字符集、还有个什么的字符集来着，要保持一致。

```sql
```

### 导出

```sh
mysqldump -h 192.168.2.184 -u root -p password --databases db_name > db_name.sql             # 导出 db_name 数据库
mysqldump -h 192.168.2.184 -u root -p password --databases db_name users > db_name_users.sql # 导出 db_name 数据库 users 表
mysqldump --default-character-set=utf8 ... # 指定 utf8 字符集
# -s, silent, 只返回查询结果，不展示表头、分割线、行号等信息

mysql -h$host -u$user -p$password -D$db -B -e "$sql" > export.csv
```

### 索引

```sql
show index from phone_location;
DROP INDEX [indexName] ON mytable;
CREATE INDEX indexName ON table_name (column_name)
```

## 本地快速搭建

```sh
service docker start  # 启动 docker
docker pull mysql:5.6 # 下载 docker mysql 5.6
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 \
    -v $PWD/conf:/etc/mysql/conf.d \
    -v $PWD/data:/var/lib/mysql \
    -v $PWD/logs:/logs \
    --name test_mysql mysql:5.6 # 启动，注意创建本地 conf data logs 目录
mysql -uroot -p123456                          # 在 docker 内连接
source /var/lib/mysql/udesk_phone_location.sql # 在 mysql 交互页中执行导入
```

mysql 操作

```sql
-- 创建 DB
CREATE DATABASE test_db;
CREATE DATABASE IF NOT EXISTS test_db;
CREATE DATABASE t1_freeswitch  DEFAULT CHARSET utf8;
CREATE DATABASE t1_freeswitch  DEFAULT CHARSET utf8;
CREATE DATABASE t1_freeswitch  DEFAULT CHARSET utf8mb4;

show create database t1_freeswitch;

-- 创建表
CREATE TABLE `kefu` (
  `sid` varchar(255) DEFAULT NULL,
  `name_from_kefu` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 导入 csv（注意表头和表字段一致）
-- shell 中将文件放到对应目录 cp train.csv /var/lib/mysql-files/
LOAD DATA INFILE '/var/lib/mysql-files/crm.csv'
    INTO TABLE crm
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
```

## 高级

```sh
# 使用 prepare
PREPARE stmt1 from "select agent_id,id,ready_at from agents where ready_at> ? limit 1;";
SET @pc = '2023-05-10';
EXECUTE stmt1 USING @pc;
DEALLOCATE PREPARE stmt1;
# 查看当前状态：准备语句 的个数
SHOW GLOBAL STATUS LIKE 'Prepared_stmt_count';
# 查看 mysql 准备语句 最大配置数
SHOW VARIABLES LIKE 'max_prepared_stmt_count';

# 设置 max_prepared_stmt_count （默认 16382）
SET GLOBAL max_prepared_stmt_count = 16382;
```

select ccps.sid,ccps.name_from_ccps,crm.name_from_crm,kefu.name_from_kefu from ccps left join crm on ccps.sid=crm.sid left join kefu on ccps.sid=kefu.sid;
