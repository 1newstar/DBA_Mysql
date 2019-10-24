## 命令准备

# 修改库的字符编码和校验码，RDS控制台刷新后自动变更
ALTER DATABASE db1 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
# 修改表的字符集和校验码
ALTER TABLE t1 CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
# 修改表后，字段自动变更


### 查看指定数据库字符集明细

```sql
SELECT table_name, CHARACTER_SET_NAME,COLLATION_NAME
FROM information_schema.TABLES AS T, information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` AS C
WHERE C.collation_name = T.table_collation
AND T.table_schema = 'yourdb'
AND
(
C.CHARACTER_SET_NAME != 'utf8mb4'
OR
C.COLLATION_NAME != 'utf8mb4_unicode_ci'
);

SELECT 
    table_schema,
    table_name,
    COLUMN_NAME,
    CHARACTER_SET_NAME,
    COLLATION_NAME
FROM
    information_schema.columns
WHERE
    table_schema = 'yourdb'
        AND (CHARACTER_SET_NAME != 'utf8mb4'
        OR COLLATION_NAME != 'utf8mb4_unicode_ci');
```

### 生成修改字符集的命令

```sql
SELECT CONCAT('ALTER TABLE ', table_name, ' CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
FROM information_schema.TABLES AS T, information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` AS C
WHERE C.collation_name = T.table_collation
AND T.table_schema = 'ecshoptest'
AND
(
 C.CHARACTER_SET_NAME != 'utf8mb4'
 OR
 C.COLLATION_NAME != 'utf8mb4_unicode_ci'
);
```

## 参考

[confluence业务](https://confluence.atlassian.com/kb/how-to-fix-the-collation-and-character-set-of-a-mysql-database-744326173.html?spm=a2c4e.10696291.0.0.d80619a4Csljrv)

## 测试

```sql
-- 查看指定列的字符集和排序规则
select table_schema,table_name,COLUMN_NAME,CHARACTER_SET_NAME,COLLATION_NAME from information_schema.columns where table_schema='booboo' and table_name='t2';
-- 变更表和列的字符集和排序规则
alter table t2  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```


验证明细

```bash
root@MySQL-01 10:00:  [booboo]> select table_name,CHARACTER_SET_NAME,COLLATION_NAME from information_schema.columns where table_schema='booboo' and table_name='t2';
+------------+--------------------+--------------------+
| table_name | CHARACTER_SET_NAME | COLLATION_NAME     |
+------------+--------------------+--------------------+
| t2         | NULL               | NULL               |
| t2         | utf8mb4            | utf8mb4_unicode_ci |
+------------+--------------------+--------------------+
2 rows in set (0.00 sec)

root@MySQL-01 10:01:  [booboo]> select table_name,CHARACTER_SET_NAME,COLLATION_NAME from information_schema.columns where table_schema='booboo' and table_name='t2';
+------------+--------------------+--------------------+
| table_name | CHARACTER_SET_NAME | COLLATION_NAME     |
+------------+--------------------+--------------------+
| t2         | NULL               | NULL               |
| t2         | utf8mb4            | utf8mb4_unicode_ci |
+------------+--------------------+--------------------+
2 rows in set (0.01 sec)

root@MySQL-01 10:01:  [booboo]> select table_schema,table_name,COLUMN_NAME,CHARACTER_SET_NAME,COLLATION_NAME from information_schema.columns where table_schema='booboo' and table_name='t2';
+--------------+------------+-------------+--------------------+--------------------+
| table_schema | table_name | COLUMN_NAME | CHARACTER_SET_NAME | COLLATION_NAME     |
+--------------+------------+-------------+--------------------+--------------------+
| booboo       | t2         | id          | NULL               | NULL               |
| booboo       | t2         | name        | utf8mb4            | utf8mb4_unicode_ci |
+--------------+------------+-------------+--------------------+--------------------+
2 rows in set (0.00 sec)

root@MySQL-01 10:02:  [booboo]> alter table t2  CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;
Query OK, 0 rows affected (0.05 sec)
Records: 0  Duplicates: 0  Warnings: 0

root@MySQL-01 10:02:  [booboo]> select table_schema,table_name,COLUMN_NAME,CHARACTER_SET_NAME,COLLATION_NAME from information_schema.columns where table_schema='booboo' and table_name='t2';
+--------------+------------+-------------+--------------------+-----------------+
| table_schema | table_name | COLUMN_NAME | CHARACTER_SET_NAME | COLLATION_NAME  |
+--------------+------------+-------------+--------------------+-----------------+
| booboo       | t2         | id          | NULL               | NULL            |
| booboo       | t2         | name        | utf8               | utf8_unicode_ci |
+--------------+------------+-------------+--------------------+-----------------+
2 rows in set (0.00 sec)

root@MySQL-01 10:02:  [booboo]> show create table t2\G;
*************************** 1. row ***************************
       Table: t2
Create Table: CREATE TABLE `t2` (
  `id` int(11) NOT NULL,
  `name` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci
1 row in set (0.00 sec)

ERROR:
No query specified

root@MySQL-01 10:03:  [booboo]> alter table t2  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

root@MySQL-01 10:03:  [booboo]> show create table t2\G;
*************************** 1. row ***************************
       Table: t2
Create Table: CREATE TABLE `t2` (
  `id` int(11) NOT NULL,
  `name` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
1 row in set (0.00 sec)

ERROR:
No query specified

root@MySQL-01 10:03:  [booboo]> select table_schema,table_name,COLUMN_NAME,CHARACTER_SET_NAME,COLLATION_NAME from information_schema.columns where table_schema='booboo' and table_name='t2';
+--------------+------------+-------------+--------------------+--------------------+
| table_schema | table_name | COLUMN_NAME | CHARACTER_SET_NAME | COLLATION_NAME     |
+--------------+------------+-------------+--------------------+--------------------+
| booboo       | t2         | id          | NULL               | NULL               |
| booboo       | t2         | name        | utf8mb4            | utf8mb4_unicode_ci |
+--------------+------------+-------------+--------------------+--------------------+
2 rows in set (0.00 sec)
```
