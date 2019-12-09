# mysql 5.6 innodb 存储引擎分区表数据紧急救援

```sql
--模拟5.6生产环境-分区表数据
root@mysqldb 06:02:  [(none)]> select @@version;
+------------+
| @@version  |
+------------+
| 5.6.35-log |
+------------+
1 row in set (0.01 sec)

root@mysqldb 06:02:  [(none)]> create database booboo;
Query OK, 1 row affected (0.00 sec)

root@mysqldb 06:02:  [(none)]> use booboo
Database changed
root@mysqldb 06:03:  [booboo]> show tables;
Empty set (0.00 sec)

root@mysqldb 06:03:  [booboo]> CREATE TABLE `t1` (
    ->   `id` int(11) NOT NULL,
    ->   `col1` int(11) NOT NULL,
    ->   PRIMARY KEY (`id`,`col1`)
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    -> /*!50100 PARTITION BY RANGE (col1)
    -> (PARTITION p100 VALUES LESS THAN (100) ENGINE = InnoDB,
    ->  PARTITION p101 VALUES LESS THAN (200) ENGINE = InnoDB) */;
Query OK, 0 rows affected (0.10 sec)


root@mysqldb 06:05:  [booboo]> insert into t1 values (1,99),(2,199);
Query OK, 2 row affected (0.01 sec)

root@mysqldb 06:06:  [booboo]> select * from t1;
+----+------+
| id | col1 |
+----+------+
|  1 |   99 |
|  2 |  199 |
+----+------+
2 rows in set (0.00 sec)



--5.7模拟恢复
root@MySQL-01 21:11:  [booboo]> show tables;
+------------------+
| Tables_in_booboo |
+------------------+
| t1               |
+------------------+
1 row in set (0.00 sec)

root@MySQL-01 21:11:  [booboo]> alter table t1 discard tablespace;
Query OK, 0 rows affected (0.02 sec)

--从5.6上将数据复制到5.7的目录中
[root@oratest booboo]# ll
total 212
-rw-rw---- 1 mysql mysql    67 Nov  9 06:02 db.opt
-rw-rw---- 1 mysql mysql  8586 Nov  9 06:04 t1.frm
-rw-rw---- 1 mysql mysql    32 Nov  9 06:04 t1.par
-rw-rw---- 1 mysql mysql 98304 Nov  9 06:06 t1#P#p100.ibd
-rw-rw---- 1 mysql mysql 98304 Nov  9 06:05 t1#P#p101.ibd
[root@oratest booboo]# scp t1*.ibd root@47.100.48.213:/alidata/mysql/data_booboo/booboo
root@47.100.48.213's password: 
t1#P#p100.ibd                                          100%   96KB  96.0KB/s   00:00    
t1#P#p101.ibd                                          100%   96KB  96.0KB/s   00:00   


--5.7上检查
[root@tick:/alidata/mysql/data_booboo/booboo]# pwd
/alidata/mysql/data_booboo/booboo
[root@tick:/alidata/mysql/data_booboo/booboo]# ll
total 208
-rw-r----- 1 mysql mysql    67 Nov  8 00:35 db.opt
-rw-r----- 1 mysql mysql  8586 Nov  9 21:10 t1.frm
-rw-r----- 1 root  root  98304 Nov  9 22:14 t1#P#p100.ibd
-rw-r----- 1 root  root  98304 Nov  9 22:14 t1#P#p101.ibd
[root@tick:/alidata/mysql/data_booboo/booboo]# chown mysql. -R ./
[root@tick:/alidata/mysql/data_booboo/booboo]# ll
total 208
-rw-r----- 1 mysql mysql    67 Nov  8 00:35 db.opt
-rw-r----- 1 mysql mysql  8586 Nov  9 21:10 t1.frm
-rw-r----- 1 mysql mysql 98304 Nov  9 22:14 t1#P#p100.ibd
-rw-r----- 1 mysql mysql 98304 Nov  9 22:14 t1#P#p101.ibd


root@MySQL-01 21:19:  [booboo]> show tables;
+------------------+
| Tables_in_booboo |
+------------------+
| t1               |
+------------------+
1 row in set (0.00 sec)

root@MySQL-01 22:16:  [booboo]> alter table t1 import tablespace;
ERROR 1808 (HY000): Schema mismatch (Table has ROW_TYPE_DYNAMIC row format, .ibd file has ROW_TYPE_COMPACT row format.)

--报错行格式不同，对比5.6和5.7的行格式
--5.6
root@mysqldb 06:18:  [booboo]> show table status like 't1'\G;
*************************** 1. row ***************************
           Name: t1
         Engine: InnoDB
        Version: 10
     Row_format: Compact
           Rows: 2
 Avg_row_length: 16384
    Data_length: 32768
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2019-11-09 06:04:02
    Update_time: NULL
     Check_time: NULL
      Collation: utf8mb4_general_ci
       Checksum: NULL
 Create_options: partitioned
        Comment: 
1 row in set (0.00 sec)
--5.7
root@MySQL-01 22:18:  [booboo]> show table status like 't1'\G
*************************** 1. row ***************************
           Name: t1
         Engine: InnoDB
        Version: 10
     Row_format: Dynamic
           Rows: 2
 Avg_row_length: 16384
    Data_length: 32768
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2019-11-09 22:15:34
    Update_time: NULL
     Check_time: NULL
      Collation: utf8mb4_general_ci
       Checksum: NULL
 Create_options: partitioned
        Comment: 
1 row in set, 2 warnings (0.00 sec)

--问题确认：5.7默认行格式为dynamic，而5.6为compact，因此需要修改一致。
--5.7执行alter修改行格式操作
root@MySQL-01 22:18:  [booboo]> alter table t1 row_format=compact;
Query OK, 0 rows affected, 1 warning (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 1

root@MySQL-01 22:23:  [booboo]> show table status like 't1'\G
*************************** 1. row ***************************
           Name: t1
         Engine: InnoDB
        Version: 10
     Row_format: Compact
           Rows: 0
 Avg_row_length: 0
    Data_length: 32768
Max_data_length: 0
   Index_length: 0
      Data_free: 0
 Auto_increment: NULL
    Create_time: 2019-11-09 22:23:45
    Update_time: NULL
     Check_time: NULL
      Collation: utf8mb4_general_ci
       Checksum: NULL
 Create_options: row_format=COMPACT partitioned
        Comment: 
1 row in set, 2 warnings (0.01 sec)

root@MySQL-01 22:24:  [booboo]> alter table t1 import tablespace;
Query OK, 0 rows affected, 2 warnings (0.13 sec)

root@MySQL-01 22:25:  [booboo]> select * from t1;
+----+------+
| id | col1 |
+----+------+
|  1 |   99 |
|  2 |  199 |
+----+------+
2 rows in set (0.00 sec)
```
