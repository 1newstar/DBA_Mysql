# MySQL5.6数据库归档测试

> 2018-08-10 大宝

[TOC]




## 归档工具

`percona-toolkit-3.0.11 `

##软件下载地址

https://www.percona.com/downloads/percona-toolkit/3.0.11/binary/tarball/percona-toolkit-3.0.11_x86_64.tar.gz

https://www.percona.com/downloads/percona-toolkit/3.0.12/binary/tarball/percona-toolkit-3.0.12_x86_64.tar.gz

## 安装

```shell
[root@sh_02 install]# curl -O "https://www.percona.com/downloads/percona-toolkit/3.0.11/binary/tarball/percona-toolkit-3.0.11_x86_64.tar.gz"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 7979k  100 7979k    0     0   251k      0  0:00:31  0:00:31 --:--:--  357k
[root@sh_02 install]# tar -xf percona-toolkit-3.0.11_x86_64.tar.gz
[root@sh_02 install]# cd percona-toolkit-3.0.11
[root@sh_02 percona-toolkit-3.0.11]# ll
total 120
drwxrwxr-x. 2 500 500  4096 Jul  6 23:14 bin
-rw-rw-r--. 1 500 500 50938 Jul  6 23:14 Changelog
-rw-rw-r--. 1 500 500  7142 Jul  6 23:14 CONTRIBUTE.md
-rw-rw-r--. 1 500 500   224 Jul  6 23:14 CONTRIBUTING.md
-rw-rw-r--. 1 500 500 18092 Jul  6 23:14 COPYING
-rw-rw-r--. 1 500 500   129 Jul  6 23:14 docker-compose.yml
drwxrwxr-x. 2 500 500    33 Jul  6 23:14 docs
-rw-rw-r--. 1 500 500  4800 Jul  6 23:14 Gopkg.lock
-rw-rw-r--. 1 500 500  1477 Jul  6 23:14 Gopkg.toml
-rw-rw-r--. 1 500 500  1527 Jul  6 23:14 INSTALL
drwxrwxr-x. 2 500 500     6 Jul  6 23:14 lib
-rw-rw-r--. 1 500 500   568 Jul  6 23:14 Makefile.PL
-rw-rw-r--. 1 500 500   809 Jul  6 23:14 MANIFEST
-rw-rw-r--. 1 500 500  1692 Jul  6 23:14 README.md
[root@sh_02 install]# mv percona-toolkit-3.0.11 ../
[root@sh_02 install]# echo "export PATH=\$PATH:/alidata/percona-toolkit-3.0.11/bin" >> /etc/profile
[root@sh_02 install]# yum install -y  perl perl-devel perl-Time-HiRes  perl-DBI perl-DBD-MySQL perl-Digest-MD5
[root@sh_02 install]# yum install cmake gcc gcc-c++ libaio libaio-devel automake autoconf bzr bison libtool ncurses5-devel
```

## 归档命令

```shell
[root@sh_02 alidata]# tree /alidata/percona-toolkit-3.0.11/
percona-toolkit-3.0.11/
├── bin
│   ├── pt-align
│   ├── pt-archiver
│   ├── pt-config-diff
│   ├── pt-deadlock-logger
│   ├── pt-diskstats
│   ├── pt-duplicate-key-checker
│   ├── pt-fifo-split
│   ├── pt-find
│   ├── pt-fingerprint
│   ├── pt-fk-error-logger
│   ├── pt-heartbeat
│   ├── pt-index-usage
│   ├── pt-ioprofile
│   ├── pt-kill
│   ├── pt-mext
│   ├── pt-mongodb-query-digest
│   ├── pt-mongodb-summary
│   ├── pt-mysql-summary
│   ├── pt-online-schema-change
│   ├── pt-pmp
│   ├── pt-query-digest
│   ├── pt-secure-collect
│   ├── pt-show-grants
│   ├── pt-sift
│   ├── pt-slave-delay
│   ├── pt-slave-find
│   ├── pt-slave-restart
│   ├── pt-stalk
│   ├── pt-summary
│   ├── pt-table-checksum
│   ├── pt-table-sync
│   ├── pt-table-usage
│   ├── pt-upgrade
│   ├── pt-variable-advisor
│   └── pt-visual-explain
├── Changelog
├── CONTRIBUTE.md
├── CONTRIBUTING.md
├── COPYING
├── docker-compose.yml
├── docs
│   └── percona-toolkit.pod
├── Gopkg.lock
├── Gopkg.toml
├── INSTALL
├── lib
├── Makefile.PL
├── MANIFEST
└── README.md

3 directories, 47 files

```

## 命令测试

```shell
# 测试数据库中建两张表，test和test_p ，他们之间的关系是test.user_id=test_p.user_id
root@SH_MySQL-01 15:19:  [uplooking]> use dba;
Database changed
root@SH_MySQL-01 15:22:  [dba]> show tables;
Empty set (0.00 sec)

root@SH_MySQL-01 15:22:  [dba]> create table test(
    -> userid int(4) primary key not null auto_increment,
    -> username varchar(50) not null,
    -> userpassword varchar(32) not null,
    -> nowtime datetime default CURRENT_TIMESTAMP
    -> );
Query OK, 0 rows affected (0.04 sec)

root@SH_MySQL-01 15:22:  [dba]> insert into test values (null,'er','eesss',now());
Query OK, 1 row affected (0.01 sec)

root@SH_MySQL-01 15:22:  [dba]> insert into test values (null,'er','sss',now());
Query OK, 1 row affected (0.01 sec)

root@SH_MySQL-01 15:22:  [dba]> insert into test values (null,'aer','sss',now());
Query OK, 1 row affected (0.00 sec)

root@SH_MySQL-01 15:22:  [dba]> select * from test;
+--------+----------+--------------+---------------------+
| userid | username | userpassword | nowtime             |
+--------+----------+--------------+---------------------+
|      1 | er       | eesss        | 2018-08-10 15:22:31 |
|      2 | er       | sss          | 2018-08-10 15:22:37 |
|      3 | aer      | sss          | 2018-08-10 15:22:43 |
+--------+----------+--------------+---------------------+
3 rows in set (0.00 sec)

root@SH_MySQL-01 15:22:  [dba]> insert into test values (null,'superman','sss',now());
Query OK, 1 row affected (0.01 sec)

root@SH_MySQL-01 15:23:  [dba]> insert into test values (null,'batman','sss',now());
Query OK, 1 row affected (0.00 sec)

root@SH_MySQL-01 15:23:  [dba]> insert into test values (null,'supergirl','sss',now());
Query OK, 1 row affected (0.01 sec)

root@SH_MySQL-01 15:23:  [dba]> select * from test;
+--------+-----------+--------------+---------------------+
| userid | username  | userpassword | nowtime             |
+--------+-----------+--------------+---------------------+
|      1 | er        | eesss        | 2018-08-10 15:22:31 |
|      2 | er        | sss          | 2018-08-10 15:22:37 |
|      3 | aer       | sss          | 2018-08-10 15:22:43 |
|      4 | superman  | sss          | 2018-08-10 15:23:06 |
|      5 | batman    | sss          | 2018-08-10 15:23:12 |
|      6 | supergirl | sss          | 2018-08-10 15:23:18 |
+--------+-----------+--------------+---------------------+
6 rows in set (0.00 sec)

root@SH_MySQL-01 15:23:  [dba]> create table test_p(
    -> id int(4) primary key not null auto_increment,
    -> userid int(4) not null,
    -> username varchar(50) not null,
    -> userpassword varchar(32) not null,
    -> nowtime datetime default CURRENT_TIMESTAMP
    -> );
Query OK, 0 rows affected (0.04 sec)

root@SH_MySQL-01 15:24:  [dba]> insert into test_p values (null,'3','aer','ssss',now());
Query OK, 1 row affected (0.01 sec)

root@SH_MySQL-01 15:24:  [dba]> insert into test_p values (null,'5','aer','ssss',now());
Query OK, 1 row affected (0.00 sec)

root@SH_MySQL-01 15:24:  [dba]> select * from test_p;
+----+--------+----------+--------------+---------------------+
| id | userid | username | userpassword | nowtime             |
+----+--------+----------+--------------+---------------------+
|  1 |      3 | aer      | ssss         | 2018-08-10 15:24:25 |
|  2 |      5 | aer      | ssss         | 2018-08-10 15:24:30 |
+----+--------+----------+--------------+---------------------+
2 rows in set (0.00 sec)

# test_1为将来存放归档数据的表，需要提前新建出来
root@SH_MySQL-01 15:24:  [dba]> create table test_1(
    -> userid int(4) primary key not null auto_increment,
    -> username varchar(50) not null,
    -> userpassword varchar(32) not null,
    -> nowtime datetime default CURRENT_TIMESTAMP
    -> );
Query OK, 0 rows affected (0.03 sec)
# test_p_1 为将来存放归档数据的表，需要提前新建
root@SH_MySQL-01 15:46:  [dba]> create table test_p_1(
    -> id int(4) primary key not null auto_increment,
    -> userid int(4) not null,
    -> username varchar(50) not null,
    -> userpassword varchar(32) not null,
    -> nowtime datetime default CURRENT_TIMESTAMP
    -> );
Query OK, 0 rows affected (0.04 sec)

```

* 开始归档test表中的数据
* 将`nowtime<"2018-08-10 15:22:43"`的数据归档，并删除


```shell
[root@sh_02 alidata]# pt-archiver --source h=10.200.6.30,p=3306,u=php,p='uplooking',D=dba,t=test --dest h=10.200.6.30,p=3306,u=php,p=uplooking,D=dba,t=test_1 --no-check-charset --where 'nowtime<"2018-08-10 15:22:43"' --progress 10 --limit=10 --txn-size 10 --bulk-insert --bulk-delete --statistics --purge
TIME                ELAPSED   COUNT
2018-08-10T15:36:49       0       0
2018-08-10T15:36:49       0       2
Started at 2018-08-10T15:36:49, ended at 2018-08-10T15:36:49
Source: D=dba,h=10.200.6.30,p=...,t=test,u=php
Dest:   D=dba,h=10.200.6.30,p=...,t=test_1,u=php
SELECT 2
INSERT 2
DELETE 2
Action              Count       Time        Pct
commit                  2     0.0113      57.21
bulk_inserting          1     0.0008       3.92
select                  2     0.0005       2.47
bulk_deleting           1     0.0003       1.76
print_bulkfile          2     0.0000       0.02
other                   0     0.0069      34.61

# 查看归档前后的表数据情况
## 归档前的test
root@SH_MySQL-01 15:35:  [dba]> select * from test;
+--------+-----------+--------------+---------------------+
| userid | username  | userpassword | nowtime             |
+--------+-----------+--------------+---------------------+
|      1 | er        | eesss        | 2018-08-10 15:22:31 |
|      2 | er        | sss          | 2018-08-10 15:22:37 |
|      3 | aer       | sss          | 2018-08-10 15:22:43 |
|      4 | superman  | sss          | 2018-08-10 15:23:06 |
|      5 | batman    | sss          | 2018-08-10 15:23:12 |
|      6 | supergirl | sss          | 2018-08-10 15:23:18 |
+--------+-----------+--------------+---------------------+
6 rows in set (0.00 sec)
## 归档后的test
root@SH_MySQL-01 15:35:  [dba]> select * from test;
+--------+-----------+--------------+---------------------+
| userid | username  | userpassword | nowtime             |
+--------+-----------+--------------+---------------------+
|      3 | aer       | sss          | 2018-08-10 15:22:43 |
|      4 | superman  | sss          | 2018-08-10 15:23:06 |
|      5 | batman    | sss          | 2018-08-10 15:23:12 |
|      6 | supergirl | sss          | 2018-08-10 15:23:18 |
+--------+-----------+--------------+---------------------+
4 rows in set (0.00 sec)
## 归档表test1
root@SH_MySQL-01 15:45:  [dba]> select * from test_1;
+--------+----------+--------------+---------------------+
| userid | username | userpassword | nowtime             |
+--------+----------+--------------+---------------------+
|      1 | er       | eesss        | 2018-08-10 15:22:31 |
|      2 | er       | sss          | 2018-08-10 15:22:37 |
+--------+----------+--------------+---------------------+
2 rows in set (0.00 sec)
```

* 开始归档`test_p`表中的数据
* 将`user_id<=5`的数据归档，并删除
`--where 'userid<=5'`

```shell
[root@sh_02 alidata]# pt-archiver --source h=10.200.6.30,p=3306,u=php,p='uplooking',D=dba,t=test_p --dest h=10.200.6.30,p=3306,u=php,p=uplooking,D=dba,t=test_p_1 --no-check-charset --where 'userid<=5' --progress 10 --limit=10 --txn-size 10 --bulk-insert --bulk-delete --statistics --purge
TIME                ELAPSED   COUNT
2018-08-10T15:52:30       0       0
2018-08-10T15:52:30       0       1
Started at 2018-08-10T15:52:30, ended at 2018-08-10T15:52:30
Source: D=dba,h=10.200.6.30,p=...,t=test_p,u=php
Dest:   D=dba,h=10.200.6.30,p=...,t=test_p_1,u=php
SELECT 1
INSERT 1
DELETE 1
Action              Count       Time        Pct
commit                  2     0.0060      41.84
bulk_inserting          1     0.0008       5.91
select                  2     0.0007       4.98
bulk_deleting           1     0.0003       1.88
print_bulkfile          1     0.0000       0.08
other                   0     0.0065      45.32

# test_p归档前
root@SH_MySQL-01 15:52:  [dba]> select * from test_p;
+----+--------+----------+--------------+---------------------+
| id | userid | username | userpassword | nowtime             |
+----+--------+----------+--------------+---------------------+
|  1 |      3 | aer      | ssss         | 2018-08-10 15:24:25 |
|  2 |      5 | aer      | ssss         | 2018-08-10 15:24:30 |
+----+--------+----------+--------------+---------------------+
2 rows in set (0.00 sec)
# test_p归档后
root@SH_MySQL-01 15:52:  [dba]> select * from test_p;
+----+--------+----------+--------------+---------------------+
| id | userid | username | userpassword | nowtime             |
+----+--------+----------+--------------+---------------------+
|  2 |      5 | aer      | ssss         | 2018-08-10 15:24:30 |
+----+--------+----------+--------------+---------------------+
1 row in set (0.00 sec)
# test_p_1归档表中的数据
root@SH_MySQL-01 15:52:  [dba]> select * from test_p_1;
+----+--------+----------+--------------+---------------------+
| id | userid | username | userpassword | nowtime             |
+----+--------+----------+--------------+---------------------+
|  1 |      3 | aer      | ssss         | 2018-08-10 15:24:25 |
+----+--------+----------+--------------+---------------------+
1 row in set (0.00 sec)
# 可以看到<=符号没有将=的数据过滤出来。
```

## 修改源码

```shell
pt-archiverBug不会迁移max(id)那条数据的解决方法

[root@sh_02 bin]# vim pt-archiver 

#修改前
6401       $first_sql .= " AND ($col < " . $q->quote_val($val) . ")";
#修改后
6401       $first_sql .= " AND ($col <= " . $q->quote_val($val) . ")";
```



## 再次测试

```shell
root@SH_MySQL-01 15:52:  [dba]> insert into test_p values (null,'3','aer','ssss',now());
Query OK, 1 row affected (0.01 sec)

root@SH_MySQL-01 16:01:  [dba]> insert into test_p values (null,'3','aer','ssss',now());
Query OK, 1 row affected (0.00 sec)

root@SH_MySQL-01 16:01:  [dba]> insert into test_p values (null,'3','aer','ssss',now());
Query OK, 1 row affected (0.00 sec)

root@SH_MySQL-01 16:01:  [dba]> insert into test_p values (null,'3','aer','ssss',now());
Query OK, 1 row affected (0.00 sec)

root@SH_MySQL-01 16:01:  [dba]> select * from test_p;
+----+--------+----------+--------------+---------------------+
| id | userid | username | userpassword | nowtime             |
+----+--------+----------+--------------+---------------------+
|  2 |      5 | aer      | ssss         | 2018-08-10 15:24:30 |
|  3 |      3 | aer      | ssss         | 2018-08-10 16:01:50 |
|  4 |      3 | aer      | ssss         | 2018-08-10 16:01:50 |
|  5 |      3 | aer      | ssss         | 2018-08-10 16:01:51 |
|  6 |      3 | aer      | ssss         | 2018-08-10 16:01:52 |
+----+--------+----------+--------------+---------------------+
5 rows in set (0.00 sec)

[root@sh_02 bin]# pt-archiver --source h=10.200.6.30,p=3306,u=php,p='uplooking',D=dba,t=test_p --dest h=10.200.6.30,p=3306,u=php,p=uplooking,D=dba,t=test_p_1 --no-check-charset --where 'userid<=5' --progress 10 --limit=10 --txn-size 10 --bulk-insert --bulk-delete --statistics --purge
TIME                ELAPSED   COUNT
2018-08-10T16:02:28       0       0
2018-08-10T16:02:28       0       5
Started at 2018-08-10T16:02:28, ended at 2018-08-10T16:02:28
Source: D=dba,h=10.200.6.30,p=...,t=test_p,u=php
Dest:   D=dba,h=10.200.6.30,p=...,t=test_p_1,u=php
SELECT 5
INSERT 5
DELETE 5
Action              Count       Time        Pct
commit                  2     0.0113      56.44
bulk_inserting          1     0.0007       3.59
select                  2     0.0007       3.38
bulk_deleting           1     0.0003       1.75
print_bulkfile          5    -0.0000      -0.03
other                   0     0.0070      34.87
root@SH_MySQL-01 16:01:  [dba]> select * from test_p;
Empty set (0.00 sec)

root@SH_MySQL-01 16:02:  [dba]> select * from test_p_1;
+----+--------+----------+--------------+---------------------+
| id | userid | username | userpassword | nowtime             |
+----+--------+----------+--------------+---------------------+
|  1 |      3 | aer      | ssss         | 2018-08-10 15:24:25 |
|  2 |      5 | aer      | ssss         | 2018-08-10 15:24:30 |
|  3 |      3 | aer      | ssss         | 2018-08-10 16:01:50 |
|  4 |      3 | aer      | ssss         | 2018-08-10 16:01:50 |
|  5 |      3 | aer      | ssss         | 2018-08-10 16:01:51 |
|  6 |      3 | aer      | ssss         | 2018-08-10 16:01:52 |
+----+--------+----------+--------------+---------------------+
6 rows in set (0.00 sec)
# 测试成功
```

