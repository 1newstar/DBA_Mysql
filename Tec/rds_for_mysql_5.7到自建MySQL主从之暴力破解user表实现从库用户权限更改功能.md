# RDS For MySQL 5.7到自建MySQL主从之暴力破解user表实现从库用户权限更改功能

> 2018-08-14 大宝

[TOC]

# 故事背景

## 数据库明细

说在前面：

* 云上数据库： RDS For MySQL 5.7.20 普通用户权限
* IDC数据库: MySQL 5.7.20 

## 故事情节

现需要搭建RDS For MySQL 到线下IDC机房的主从，问题如下：

### 同步系统表失败

#### 故障原因

- RDS For MySQL 5.7.20 到自建MySQL 5.7.20主从同步异常的原因为RDS与MySQL官方版本使用的系统库不同
- 自建MySQL 5.7.20 无法同步主库RDS的系统表
- 自建MySQL 5.7.20 恢复RDS的全备份数据后无法执行授权语句,报错如下：

```shell
ERROR 1785 (HY000): Statement violates GTID consistency: Updates to non-transactional tables can only be done in either autocommitted statements or single-statement transactions, and never in the same statement as updates to transactional tables.
```

- 自建MySQL 5.7.20 恢复RDS的全备份数据后无法对系统表执行更新操作，报错如下：

```shell
ERROR 1064 (42000): Unknown trigger has an error in its body: 'Unknown system variable 'maintain_user_list''
```

#### 解决方法

* 跳过系统表的同步

---

### 从库添加认证授权失败

RDS For MySQL 5.7.20 到自建MySQL 5.7.20 搭建主从同步架构:

- 配置从库不同步RDS主库的系统表

```
# skip rep
replicate_wild_ignore_table=mysql.%
replicate_wild_ignore_table=sys.%
replicate_wild_ignore_table=information_schema.%
```

- **非系统库数据同步正常**
- 从库无法执行grant命令，即无法添加授权信息
- 从库无法对系统表mysql.user表执行insert操作
- 从库无法对系统表mysql.user表执行updat操作

报错如下：

```shell
ERROR 1064 (42000): Unknown trigger has an error in its body: 'Unknown system variable 'maintain_user_list''
```

#### 失败原因

**阿里工单答复**：RDS 目前已经不支持 MYISAM 引擎创建了。所以如果是通过自建的replication 同步 就会有这个问题的，RDS 统一INNOB 引擎。
如果需求是从RDS 到自建数据库的同步关系，建议您使用DTS 做业务数据的同步。

#### 探索解决方法

##### 从库尝试使用`MySQL8.0.11`

RDS For MySQL 5.7的备份文件 到线下自建MYSQL 8.0.11 无法恢复数据。因此该方法不可行。

##### 尝试临时关闭GTID模式

1. 临时停止slave同步
2. 修改配置关闭gtid模式
3. 重启服务

对系统表mysql.user测试明细：

| No.  | 测试项目               | 结果 |
| ---- | ---------------------- | ---- |
| 1    | 是否能够执行grant命令  | ×    |
| 2    | 是否能够执行update命令 | ×    |
| 3    | 是否能够执行insert命令 | ×    |

该方法同样无法解决。

## 解决方案

### 思路

```shell
# 权限相关的一些表：
SCHEMA_PRIVILEGES：提供了数据库的相关权限，这个表是内存表是从mysql.db中拉去出来的。
TABLE_PRIVILEGES:提供的是表权限相关信息，信息是从 mysql.tables_priv 表中加载的
COLUMN_PRIVILEGES ：这个表可以清楚就能看到表授权的用户的对象，那张表那个库以及授予的是什么权限，如果授权的时候加上with grant option的话，我们可以看得到PRIVILEGE_TYPE这个值必须是YES。
USER_PRIVILEGES:提供的是表权限相关信息，信息是从 mysql.user 表中加载的
通过表我们可以很清晰看得到MySQL授权的层次，SCHEMA，TABLE，COLUMN级别，当然这些都是基于用户来授予的
```

从数据库用户权限管理的原理可以了解到管理用户的是`user`表，如果要更细致的权限还需要`db`表和`tables_priv`表。*（本文只从user表着手）*

### 步骤概览

1. 创建新的user_1表
2. 对user_1表添加新的用户
3. 停服务
4. 将user_1替换user表
5. 启动该服务
6. 可以通过update、insert、delete操作user表来添加权限（grant无法操作）

### 测试环境

```shell
root@MySQL-01 10:35:  [mysql]> create table user_1 like user;
Query OK, 0 rows affected (0.01 sec)

root@MySQL-01 10:36:  [mysql]> select * from user_1;
Empty set (0.00 sec)

root@MySQL-01 10:36:  [mysql]> show table status like user;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'user' at line 1
root@MySQL-01 10:36:  [mysql]> show table status like 'user_1';
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+-----------+----------+----------------+-----------------------------+
| Name   | Engine | Version | Row_format | Rows | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time         | Update_time         | Check_time | Collation | Checksum | Create_options | Comment                     |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+-----------+----------+----------------+-----------------------------+
| user_1 | MyISAM |      10 | Dynamic    |    0 |              0 |           0 | 281474976710655 |         1024 |         0 |           NULL | 2019-01-04 10:36:00 | 2019-01-04 10:36:00 | NULL       | utf8_bin  |     NULL |                | Users and global privileges |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+------------+-----------+----------+----------------+-----------------------------+
1 row in set (0.00 sec)

root@MySQL-01 10:36:  [mysql]> show table status like 'user';
+------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+---------------------+-----------+----------+----------------+-----------------------------+
| Name | Engine | Version | Row_format | Rows | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time         | Update_time         | Check_time          | Collation | Checksum | Create_options | Comment                     |
+------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+---------------------+-----------+----------+----------------+-----------------------------+
| user | MyISAM |      10 | Dynamic    |    3 |             53 |         160 | 281474976710655 |         2048 |         0 |           NULL | 2015-05-22 15:24:42 | 2019-01-04 09:27:49 | 2015-05-22 15:33:22 | utf8_bin  |     NULL |                | Users and global privileges |
+------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+---------------------+---------------------+---------------------+-----------+----------+----------------+-----------------------------+
1 row in set (0.00 sec)

root@MySQL-01 10:36:  [mysql]> insert into user_1 select * from user;
Query OK, 3 rows affected (0.00 sec)
Records: 3  Duplicates: 0  Warnings: 0

root@MySQL-01 10:36:  [mysql]> select * from user_1;
+-----------+------+----------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------+-------------+--------------+---------------+-------------+-----------------+----------------------+--------+-----------------------+
| Host      | User | Password | Select_priv | Insert_priv | Update_priv | Delete_priv | Create_priv | Drop_priv | Reload_priv | Shutdown_priv | Process_priv | File_priv | Grant_priv | References_priv | Index_priv | Alter_priv | Show_db_priv | Super_priv | Create_tmp_table_priv | Lock_tables_priv | Execute_priv | Repl_slave_priv | Repl_client_priv | Create_view_priv | Show_view_priv | Create_routine_priv | Alter_routine_priv | Create_user_priv | Event_priv | Trigger_priv | Create_tablespace_priv | ssl_type | ssl_cipher | x509_issuer | x509_subject | max_questions | max_updates | max_connections | max_user_connections | plugin | authentication_string |
+-----------+------+----------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------+-------------+--------------+---------------+-------------+-----------------+----------------------+--------+-----------------------+
| localhost | root |          | Y           | Y           | Y           | Y           | Y           | Y         | Y           | Y             | Y            | Y         | Y          | Y               | Y          | Y          | Y            | Y          | Y                     | Y                | Y            | Y               | Y                | Y                | Y              | Y                   | Y                  | Y                | Y          | Y            | Y                      |          |            |             |              |             0 |           0 |               0 |                    0 |        |                       |
| 127.0.0.1 | root |          | Y           | Y           | Y           | Y           | Y           | Y         | Y           | Y             | Y            | Y         | Y          | Y               | Y          | Y          | Y            | Y          | Y                     | Y                | Y            | Y               | Y                | Y                | Y              | Y                   | Y                  | Y                | Y          | Y            | Y                      |          |            |             |              |             0 |           0 |               0 |                    0 |        |                       |
| ::1       | root |          | Y           | Y           | Y           | Y           | Y           | Y         | Y           | Y             | Y            | Y         | Y          | Y               | Y          | Y          | Y            | Y          | Y                     | Y                | Y            | Y               | Y                | Y                | Y              | Y                   | Y                  | Y                | Y          | Y            | Y                      |          |            |             |              |             0 |           0 |               0 |                    0 |        |                       |
+-----------+------+----------+-------------+-------------+-------------+-------------+-------------+-----------+-------------+---------------+--------------+-----------+------------+-----------------+------------+------------+--------------+------------+-----------------------+------------------+--------------+-----------------+------------------+------------------+----------------+---------------------+--------------------+------------------+------------+--------------+------------------------+----------+------------+-------------+--------------+---------------+-------------+-----------------+----------------------+--------+-----------------------+
3 rows in set (0.00 sec)

root@MySQL-01 10:36:  [mysql]> select user,host,authentication_string from user_1;
+------+-----------+-----------------------+
| user | host      | authentication_string |
+------+-----------+-----------------------+
| root | localhost |                       |
| root | 127.0.0.1 |                       |
| root | ::1       |                       |
+------+-----------+-----------------------+
3 rows in set (0.00 sec)

root@MySQL-01 10:36:  [mysql]> update user_1 set authentication_string=password('(Uploo00king)') where user='root';
Query OK, 3 rows affected, 1 warning (0.01 sec)
Rows matched: 3  Changed: 3  Warnings: 1

root@MySQL-01 10:37:  [mysql]> select user,host,authentication_string from user_1;
+------+-----------+-------------------------------------------+
| user | host      | authentication_string                     |
+------+-----------+-------------------------------------------+
| root | localhost | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
| root | 127.0.0.1 | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
| root | ::1       | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
+------+-----------+-------------------------------------------+
3 rows in set (0.00 sec)

root@MySQL-01 10:37:  [mysql]> exit
Bye
[root@sh_02 data]# /etc/init.d/mysqld stop
Shutting down MySQL..                                      [  OK  ]
[root@sh_02 mysql]# ll user_1*
-rw-r-----. 1 mysql mysql 10630 Jan  4 10:36 user_1.frm
-rw-r-----. 1 mysql mysql   328 Jan  4 10:37 user_1.MYD
-rw-r-----. 1 mysql mysql  2048 Jan  4 10:37 user_1.MYI
[root@sh_02 mysql]# mv user_1.frm user.frm
[root@sh_02 mysql]# mv user_1.MYD user.MYD
[root@sh_02 mysql]# mv user_1.MYI user.MYI
[root@sh_02 mysql]# ll user*
-rw-r-----. 1 mysql mysql 10630 Jan  4 10:36 user.frm
-rw-r-----. 1 mysql mysql   328 Jan  4 10:37 user.MYD
-rw-r-----. 1 mysql mysql  2048 Jan  4 10:37 user.MYI
-rw-rw----. 1 mysql mysql  3989 Aug 14 09:14 user_view.frm
[root@sh_02 mysql]# /etc/init.d/mysqld start
Starting MySQL.                                            [  OK  ]


[root@sh_02 mysql]# mysql -uroot -p'(Uploo00king)'
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 6
Server version: 5.7.20-log MySQL Community Server (GPL)

Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

root@MySQL-01 10:39:  [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| db1                |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

root@MySQL-01 10:39:  [(none)]> use mysql
Database changed
root@MySQL-01 10:39:  [mysql]> select user,host from mysql.user;
+------+-----------+
| user | host      |
+------+-----------+
| root | 127.0.0.1 |
| root | ::1       |
| root | localhost |
+------+-----------+
3 rows in set (0.00 sec)

root@MySQL-01 10:39:  [mysql]> grant all on *.* to booboo@'%' identified by '(Uploo00king)';
ERROR 1785 (HY000): Statement violates GTID consistency: Updates to non-transactional tables can only be done in either autocommitted statements or single-statement transactions, and never in the same statement as updates to transactional tables.

root@MySQL-01 11:39:  [mysql]> update mysql.user_1 set user='aliyun_root' where host='127.0.0.1';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

root@MySQL-01 11:40:  [mysql]> select user,host from mysql.user_1;
+-------------+-----------+
| user        | host      |
+-------------+-----------+
| aliyun_root | 127.0.0.1 |
| root        | ::1       |
| root        | localhost |
+-------------+-----------+
3 rows in set (0.00 sec)

aliyun_root@MySQL-01 11:51:  [mysql]> insert into mysql.user values ('%','jowing', '', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', 0, 0, 0, 0, '', password('Joowing@2017'));
Query OK, 1 row affected, 1 warning (0.01 sec)

aliyun_root@MySQL-01 11:51:  [mysql]> select user,host from  mysql.user;
+-------------+-----------+
| user        | host      |
+-------------+-----------+
| jowing      | %         |
| aliyun_root | 127.0.0.1 |
| root        | ::1       |
| root        | localhost |
+-------------+-----------+
4 rows in set (0.00 sec)

```

# 

> 2018-08-14 大宝

[TOC]

### 生产环境

#### 用户权限

目标：IDC机房从库支持通过insert、update、delete命令来修改用户权限，权限比较简单，分为只读和写。

需要设置以下权限：权限作用于所有的库多有的表

| 用户名     | 密码 | 权限 |
| :--------- | :--- | :--- |
| root       | 123  | 读写 |
| joowingbuz | 123  | 只读 |
| ottersync  | 123  | 只读 |
| syncdw     | 123  | 只读 |
| datasis    | 123  | 只读 |
| joowingv   | 123  | 只读 |
| datadev    | 123  | 只读 |
| readonly   | 123  | 只读 |

#### 步骤概览

```shell
# 1. 登陆数据库后操作如下：
use mysql;
create table user_1 like user;
insert into user_1 select * from user;
delete from mysql.user_1 where user='root';
insert into mysql.user_1 values ('%','root', '', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', 0, 0, 0, 0, '', password('123'));
insert into mysql.user_1 values ('%','joowingbuz', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
insert into mysql.user_1 values ('%','ottersync', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
insert into mysql.user_1 values ('%','syncdw', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
insert into mysql.user_1 values ('%','datasis', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
insert into mysql.user_1 values ('%','joowingv', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
insert into mysql.user_1 values ('%','datadev', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
insert into mysql.user_1 values ('%','readonly', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
# 2. 退出数据库并停止服务
/data/mysql/support-files/mysql.server stop
# 3. 将user_1表的物理文件覆盖user表
cd /data/xtrabackup_data/mysql/
mv user.frm user.ibd user.MYD user.MYI user.TRG /tmp
mv user_1.frm user.frm
mv user_1.MYI user.MYI
mv user_1.MYD user.MYD
# 4. 启动数据库
/data/mysql/support-files/mysql.server start
```

#### 操作明细

```shell
root@MySQL-01 15:42:  [(none)]> use mysql
Database changed
root@MySQL-01 15:42:  [mysql]> create table user_1 like user;
Query OK, 0 rows affected (0.01 sec)

root@MySQL-01 15:42:  [mysql]> insert into user_1 select * from user;
Query OK, 3 rows affected (0.00 sec)
Records: 3  Duplicates: 0  Warnings: 0

root@MySQL-01 15:42:  [mysql]> select user,host,authentication_string from mysql.user;
+------+-----------+-------------------------------------------+
| user | host      | authentication_string                     |
+------+-----------+-------------------------------------------+
| root | localhost | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
| root | 127.0.0.1 | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
| root | ::1       | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
+------+-----------+-------------------------------------------+
3 rows in set (0.00 sec)

root@MySQL-01 15:42:  [mysql]> select user,host,authentication_string from mysql.user_1;
+------+-----------+-------------------------------------------+
| user | host      | authentication_string                     |
+------+-----------+-------------------------------------------+
| root | localhost | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
| root | 127.0.0.1 | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
| root | ::1       | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
+------+-----------+-------------------------------------------+
3 rows in set (0.00 sec)

root@MySQL-01 15:42:  [mysql]> desc mysql.user_1;
+------------------------+-----------------------------------+------+-----+---------+-------+
| Field                  | Type                              | Null | Key | Default | Extra |
+------------------------+-----------------------------------+------+-----+---------+-------+
| Host                   | char(60)                          | NO   | PRI |         |       |
| User                   | char(16)                          | NO   | PRI |         |       |
| Password               | char(41)                          | NO   |     |         |       |
| Select_priv            | enum('N','Y')                     | NO   |     | N       |       |
| Insert_priv            | enum('N','Y')                     | NO   |     | N       |       |
| Update_priv            | enum('N','Y')                     | NO   |     | N       |       |
| Delete_priv            | enum('N','Y')                     | NO   |     | N       |       |
| Create_priv            | enum('N','Y')                     | NO   |     | N       |       |
| Drop_priv              | enum('N','Y')                     | NO   |     | N       |       |
| Reload_priv            | enum('N','Y')                     | NO   |     | N       |       |
| Shutdown_priv          | enum('N','Y')                     | NO   |     | N       |       |
| Process_priv           | enum('N','Y')                     | NO   |     | N       |       |
| File_priv              | enum('N','Y')                     | NO   |     | N       |       |
| Grant_priv             | enum('N','Y')                     | NO   |     | N       |       |
| References_priv        | enum('N','Y')                     | NO   |     | N       |       |
| Index_priv             | enum('N','Y')                     | NO   |     | N       |       |
| Alter_priv             | enum('N','Y')                     | NO   |     | N       |       |
| Show_db_priv           | enum('N','Y')                     | NO   |     | N       |       |
| Super_priv             | enum('N','Y')                     | NO   |     | N       |       |
| Create_tmp_table_priv  | enum('N','Y')                     | NO   |     | N       |       |
| Lock_tables_priv       | enum('N','Y')                     | NO   |     | N       |       |
| Execute_priv           | enum('N','Y')                     | NO   |     | N       |       |
| Repl_slave_priv        | enum('N','Y')                     | NO   |     | N       |       |
| Repl_client_priv       | enum('N','Y')                     | NO   |     | N       |       |
| Create_view_priv       | enum('N','Y')                     | NO   |     | N       |       |
| Show_view_priv         | enum('N','Y')                     | NO   |     | N       |       |
| Create_routine_priv    | enum('N','Y')                     | NO   |     | N       |       |
| Alter_routine_priv     | enum('N','Y')                     | NO   |     | N       |       |
| Create_user_priv       | enum('N','Y')                     | NO   |     | N       |       |
| Event_priv             | enum('N','Y')                     | NO   |     | N       |       |
| Trigger_priv           | enum('N','Y')                     | NO   |     | N       |       |
| Create_tablespace_priv | enum('N','Y')                     | NO   |     | N       |       |
| ssl_type               | enum('','ANY','X509','SPECIFIED') | NO   |     |         |       |
| ssl_cipher             | blob                              | NO   |     | NULL    |       |
| x509_issuer            | blob                              | NO   |     | NULL    |       |
| x509_subject           | blob                              | NO   |     | NULL    |       |
| max_questions          | int(11) unsigned                  | NO   |     | 0       |       |
| max_updates            | int(11) unsigned                  | NO   |     | 0       |       |
| max_connections        | int(11) unsigned                  | NO   |     | 0       |       |
| max_user_connections   | int(11) unsigned                  | NO   |     | 0       |       |
| plugin                 | char(64)                          | YES  |     |         |       |
| authentication_string  | text                              | YES  |     | NULL    |       |
+------------------------+-----------------------------------+------+-----+---------+-------+
42 rows in set (0.00 sec)

root@MySQL-01 15:47:  [mysql]> delete from mysql.user_1 where user='root';
Query OK, 3 rows affected (0.00 sec)

root@MySQL-01 15:51:  [mysql]> insert into mysql.user_1 values ('%','root', '', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', 0, 0, 0, 0, '', password('123'));
Query OK, 1 row affected, 1 warning (0.00 sec)

root@MySQL-01 15:52:  [mysql]> insert into mysql.user_1 values ('%','joowingbuz', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
Query OK, 1 row affected, 1 warning (0.00 sec)

root@MySQL-01 15:52:  [mysql]> insert into mysql.user_1 values ('%','ottersync', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
Query OK, 1 row affected, 1 warning (0.00 sec)

root@MySQL-01 15:52:  [mysql]> insert into mysql.user_1 values ('%','syncdw', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));

root@MySQL-01 15:52:  [mysql]> insert into mysql.user_1 values ('%','datasis', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
Query OK, 1 row affected, 1 warning (0.00 sec)

root@MySQL-01 15:52:  [mysql]> insert into mysql.user_1 values ('%','joowingv', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
Query OK, 1 row affected, 1 warning (0.01 sec)

root@MySQL-01 15:52:  [mysql]> insert into mysql.user_1 values ('%','datadev', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
Query OK, 1 row affected, 1 warning (0.00 sec)

root@MySQL-01 15:52:  [mysql]> insert into mysql.user_1 values ('%','readonly', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('123'));
Query OK, 1 row affected, 1 warning (0.00 sec)

root@MySQL-01 15:52:  [mysql]> select user,host,authentication_string from mysql.user;
+------+-----------+-------------------------------------------+
| user | host      | authentication_string                     |
+------+-----------+-------------------------------------------+
| root | localhost | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
| root | 127.0.0.1 | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
| root | ::1       | *D4DF57DFB7019B3D8C4294CC413AF1D650A275E4 |
+------+-----------+-------------------------------------------+
3 rows in set (0.00 sec)

root@MySQL-01 15:52:  [mysql]> select user,host,authentication_string from mysql.user_1;
+------------+------+-------------------------------------------+
| user       | host | authentication_string                     |
+------------+------+-------------------------------------------+
| ottersync  | %    | *9443FA914A2D69FE8832F8294E7422CC1B02A492 |
| joowingbuz | %    | *DFFDA1CA6135E355EF468AB13A465BB5D4FE2B11 |
| root       | %    | *89BE852E4EECFD217F0C5463FB30AD25BD0751E0 |
| syncdw     | %    | *3DD7B4B4F6EE968FF3452B607BDEE6294B6A425A |
| datasis    | %    | *011D511C71990F832C531A0F9CFB34CF7BB4E485 |
| joowingv   | %    | *56B364074270DF7F6D670A6B4F5A4AD13322397A |
| datadev    | %    | *D3D73E0F6BFC3159B024EF31484B6F9CC2963C5B |
| readonly   | %    | *E2BA196C0C7F409990FDB3FAB5F9C7CE95F7C449 |
+------------+------+-------------------------------------------+
8 rows in set (0.00 sec)


root@joowing-server-06:~# /data/mysql/support-files/mysql.server stop
Shutting down MySQL
...... * 


root@joowing-server-06:~# cd /data/xtrabackup_data/
root@joowing-server-06:/data/xtrabackup_data# cd mysql
root@joowing-server-06:/data/xtrabackup_data/mysql# ll user*
-rw-r----- 1 mysql mysql 10630 8月  14 15:42 user_1.frm
-rw-r----- 1 mysql mysql   744 8月  14 15:52 user_1.MYD
-rw-r----- 1 mysql mysql  2048 8月  14 15:53 user_1.MYI
-rw-r----- 1 mysql mysql 10630 8月   9 20:14 user.frm
-rw-r----- 1 mysql mysql 98304 8月   9 20:14 user.ibd
-rw-r--r-- 1 mysql mysql   328 8月   9 20:14 user.MYD
-rw-r--r-- 1 mysql mysql  2048 8月   9 20:14 user.MYI
-rw-r----- 1 mysql mysql  3569 8月   9 20:14 user.TRG
-rw-r----- 1 mysql mysql  3982 8月   9 20:14 user_view.frm
root@joowing-server-06:/data/xtrabackup_data/mysql# mv user.frm user.ibd user.MYD user.MYI user.TRG /data
root@joowing-server-06:/data/xtrabackup_data/mysql# ll user*
-rw-r----- 1 mysql mysql 10630 8月  14 15:42 user_1.frm
-rw-r----- 1 mysql mysql   744 8月  14 15:52 user_1.MYD
-rw-r----- 1 mysql mysql  2048 8月  14 15:53 user_1.MYI
-rw-r----- 1 mysql mysql  3982 8月   9 20:14 user_view.frm
root@joowing-server-06:/data/xtrabackup_data/mysql# mv user_1.frm user.frm
root@joowing-server-06:/data/xtrabackup_data/mysql# mv user_1.MYI user.MYI
root@joowing-server-06:/data/xtrabackup_data/mysql# mv user_1.MYD user.MYD
root@joowing-server-06:/data/xtrabackup_data/mysql# ll user*
-rw-r----- 1 mysql mysql 10630 8月  14 15:42 user.frm
-rw-r----- 1 mysql mysql   744 8月  14 15:52 user.MYD
-rw-r----- 1 mysql mysql  2048 8月  14 15:53 user.MYI
-rw-r----- 1 mysql mysql  3982 8月   9 20:14 user_view.frm
root@joowing-server-06:/data/xtrabackup_data/mysql# /data/mysql/support-files/mysql.server start
Starting MySQL
...... * 

root@joowing-server-06:/data/xtrabackup_data/mysql# mysql -uroot -p'123'
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.7.20-log MySQL Community Server (GPL)

Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

root@MySQL-01 15:55:  [(none)]> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: rm-uf6f05k2rg95s23bp.mysql.rds.aliyuncs.com
                  Master_User: idc_slave
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.001641
          Read_Master_Log_Pos: 447207506
               Relay_Log_File: joowing-server-06-relay-bin.000225
                Relay_Log_Pos: 35529076
        Relay_Master_Log_File: mysql-bin.001641
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: mysql.%,sys.%,information_schema.%
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 447207506
              Relay_Log_Space: 35529295
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1095052097
                  Master_UUID: b3e1de69-5daa-11e8-bed2-7cd30ab8a9fc
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: b3e1de69-5daa-11e8-bed2-7cd30ab8a9fc:97478646-97483368
            Executed_Gtid_Set: b3e1de69-5daa-11e8-bed2-7cd30ab8a9fc:1-97483368,
c39ecf19-5daa-11e8-aa9c-7cd30ac4764a:1-178658794,
c69289d7-9bc9-11e8-b922-44a842431b62:1-12
                Auto_Position: 1
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
1 row in set (0.00 sec)

ERROR: 
No query specified


# 验证只读账号
mysql -uroot	-p'123'  -e "create database dbzyadmin;"
mysql -ujoowingbuz -p'123'  -e "create database dbzyadmin;"
mysql -uottersync -p'123'  -e "create database dbzyadmin;"
mysql -usyncdw -p'123'  -e "create database dbzyadmin;"
mysql -udatasis -p'123'  -e "create database dbzyadmin;"
mysql -ujoowingv -p'123'  -e "create database dbzyadmin;"
mysql -udatadev -p'123' -e "create database dbzyadmin;"
mysql -ureadonly -p'123'  -e "create database dbzyadmin;"

# 只读账号无法执行写操作，验证成功
mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1044 (42000) at line 1: Access denied for user 'readonly'@'%' to database 'dbzyadmin'
```

#### 后续用户权限变更操作指南

> 后续新增用户、删除用户、更改密码命令如下：

##### 新增读写用户

```shell
insert into mysql.user_1 values ('%','【用户名】', '', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', 'Y', '', '', '', '', 0, 0, 0, 0, '', password('【密码】'));
```

##### 新增只读用户

```shell
insert into mysql.user_1 values ('%','【用户名】', '', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', '', '', '', 0, 0, 0, 0, '', password('【密码】'));
```

##### 删除用户命令

```shell
delete from mysql.user where user='【用户名】';
```

##### 修改密码

```shell
update mysql.user set authentication_string=password('【密码】') where user='【用户名】';
```

## 后记

RDS目前使用MySQL版本和官方在系统库上差异还是很大的，若需要搭建RDS到线下自建MySQL5.7的主从时，可以通过此法去实现。

本文中对user表的破解，同样适适用于`mysql.db` 、`mysql.tables_priv`表，都破解则可以将权限从用户拓展到库表列。读者可自行实验测试。



