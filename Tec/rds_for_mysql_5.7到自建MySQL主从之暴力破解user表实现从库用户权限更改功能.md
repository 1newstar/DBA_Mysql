# RDS For MySQL 5.7 到自建MySQL 5.7 主从复制之从库权限问题的解法

> 2018-08-14 大宝

[toc]

# 故事背景

## 数据库明细

说在前面：

* 云上数据库： RDS For MySQL 5.7 普通用户权限
* IDC数据库: MySQL 5.7.20 

## 故事情节

现需要搭建RDS For MySQL 到线下IDC机房的主从，问题如下：

### 同步系统表失败

#### 故障原因

- RDS For MySQL 5.7 到自建MySQL 5.7.17 主从同步异常的原因为RDS与MySQL官方版本使用的系统库不同
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

RDS For MySQL 5.7 到自建MySQL 5.7.20 搭建主从同步架构:

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

1. 创建新的user_1表
2. 对user_1表添加新的用户
3. 停服务
4. 将user_1替换user表
5. 启动该服务
6. 可以通过update、insert、delete操作user表来添加权限（grant无法操作）


## 操作明细
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