# MySQL 5.7 group by 报错处理

> 2018-10-16 BoobooWei

[TOC]

## 报错明细

```shell
ERROR 1055 (42000): Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'uplooking.t1.age' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
```

## 报错原因

对于GROUP BY聚合操作，如果在SELECT中的列，没有在GROUP BY中出现，那么这个SQL是不合法的，因为列不在GROUP BY从句中，也就是说查出来的列必须在group by后面出现否则就会报错，或者这个字段出现在聚合函数里面。

```shell
select uname,age,count(id) from t1 group by uname;
```

该SQL中，`uanme`列并不在group by 排序中，因此报错。

## 解决方法

### 修改SQL语句

```shell
select uname,age,count(id) from t1 group by uname,age;
```

### 修改参数`sql_mode`

1. 登陆数据库，查看当前全局参数`sql_mode`的值

   ```shell
   select @@global.sql_mode;
   ```

   查询结果为：

   ```shell
   ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION 
   ```

2. 登陆数据库，修改全局参数`sql_mode`

   ```shell
   set @@global.sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
   ```

3. 应用程序重启，原因是不重启仍然使用当前session的sql_mode值。



## 本地测试

### 修改全局参数

```shell
root@SH_MySQL-01 09:49:  [uplooking]> set @@global.sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
Query OK, 0 rows affected (0.00 sec)
```

### 同一个会话进行查询

```shell
root@SH_MySQL-01 09:50:  [uplooking]> select uname,age,count(id) from t1 group by uname;                                     
ERROR 1055 (42000): Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'uplooking.t1.age' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
```

### 退出后再新开会话进行查询

```shell
root@SH_MySQL-01 09:50:  [uplooking]> exit
Bye
[root@sh_01 ~]# booboo
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 14
Server version: 5.7.17-log MySQL Community Server (GPL)

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

root@SH_MySQL-01 09:51:  [uplooking]> select @@global.sql_mode;
+------------------------------------------------------------------------------------------------------------------------+
| @@global.sql_mode                                                                                                      |
+------------------------------------------------------------------------------------------------------------------------+
| STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION |
+------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

root@SH_MySQL-01 09:51:  [uplooking]> select uname,age,count(id) from t1 group by uname;
+-------+------+-----------+
| uname | age  | count(id) |
+-------+------+-----------+
| a     |   11 |         1 |
+-------+------+-----------+
1 row in set (0.00 sec)
```

