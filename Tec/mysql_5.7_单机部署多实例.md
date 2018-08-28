# mysql_multi5.7单机多实例部署

> 2018-04-02 驻云-衾袭 

[toc]


## 配置文件

```shell
[root@hjx02 init.d]# mysqld_multi --example ## 模板文件
[root@hjx02 init.d]# vi /etc/my.cnf
[mysqld_multi]
mysqld     = /alidata/mysql/bin/mysqld_safe
mysqladmin = /alidata/mysql/bin/mysqladmin
user       = hjx
password   = 123456

[mysqld2]
socket     = /tmp/mysql.sock2
port       = 3307
pid-file   = /alidata/mysql/data2/hjx02.pid2
datadir    = /alidata/mysql/data2

[mysqld3]
socket     = /tmp/mysql.sock3
port       = 3308
pid-file   = /alidata/mysql/data3/hjx02.pid3
datadir    = /alidata/mysql/data3

[mysqld4]
socket     = /tmp/mysql.sock4
port       = 3309
pid-file   = /alidata/mysql/data4/hjx03.pid4
datadir    = /alidata/mysql/data4
```

## 启动脚本修改

```shell
[root@hjx02 support-files]# cp mysqld_multi.server /etc/init.d/mysqld_multi.server
[root@hjx02 support-files]# vi /etc/init.d/mysqld_multi.server 
#basedir=/usr/local/mysql
basedir=/alidata/mysql
#bindir=/usr/local/mysql/bin
bindir=/alidata/mysql/bin

[root@hjx02 support-files]# mysqld_multi --defaults-extra-file=/etc/my.cnf start 2,3,4
WARNING: Log file disabled. Maybe directory or file isn't writable? mysqld_multi log file version 2.16; run: 一 4月 2 14:38:02 2018 Starting MySQL servers [root@hjx02 support-files]# 2018-04-02T06:38:02.438718Z mysqld_safe Logging to '/alidata/mysql/data2/hjx02.err'. Logging to '/alidata/mysql/data2/hjx02.err'. 2018-04-02T06:38:02.454909Z mysqld_safe Logging to '/alidata/mysql/data3/hjx02.err'. Logging to '/alidata/mysql/data3/hjx02.err'. 2018-04-02T06:38:02.472418Z mysqld_safe Logging to '/alidata/mysql/data4/hjx02.err'. Logging to '/alidata/mysql/data4/hjx02.err'. 2018-04-02T06:38:02.572185Z mysqld_safe Starting mysqld daemon with databases from /alidata/mysql/data2 2018-04-02T06:38:02.585735Z mysqld_safe Starting mysqld daemon with databases from /alidata/mysql/data3 2018-04-02T06:38:02.610249Z mysqld_safe Starting mysqld daemon with databases from /alidata/mysql/data4 [root@hjx02 support-files]# mysqld_multi --defaults-extra-file=/etc/my.cnf report WARNING: Log file disabled. Maybe directory or file isn't writable?
mysqld_multi log file version 2.16; run: 一 4月  2 14:39:16 2018
Reporting MySQL servers
MySQL server from group: mysqld2 is running
MySQL server from group: mysqld3 is running
MySQL server from group: mysqld4 is running
```


## 进入每个实例只有要修改密码并创建关闭账号

在mysql5.7里用户名与密码不能一样，否则会报错。
```shell
CREATE USER 'hjx'@'localhost' IDENTIFIED BY '123456';
GRANT SHUTDOWN ON *.* TO 'hjx'@'localhost';
flush privileges;
[root@hjx02 data2]# mysql -S /tmp/mysql.sock3
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 18
Server version: 5.7.17 MySQL Community Server (GPL)

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> CREATE USER 'hjx'@'localhost' IDENTIFIED BY '123456';
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT SHUTDOWN ON *.* TO 'hjx'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.01 sec)

mysql> exit Bye
```

## 修改mysqld_multi的默认脚本

```shell
[root@hjx02 data2]# my_print_defaults -s mmysqld_multi mysqld4;
--socket=/tmp/mysql.sock4
--port=3309
--pid-file=/alidata/mysql/data4/hjx03.pid4
--datadir=/alidata/mysql/data4
[root@hjx02 data2]# my_print_defaults mysqld_multi mysqld3;
--socket=/tmp/mysql.sock3
--port=3308
--pid-file=/alidata/mysql/data3/hjx02.pid3
--datadir=/alidata/mysql/data3

[root@hjx02 data2]# vi +216 /alidata/mysql/bin/mysqld_multi 
216#my $com= join ' ', 'my_print_defaults', @defaults_options, $group;
217my $com= join ' ', 'my_print_defaults -s', @defaults_options, $group;

关闭实例
[root@hjx02 init.d]# mysqld_multi --defaults-extra-file=/etc/my.cnf stop 2
WARNING: Log file disabled. Maybe directory or file isn't writable? mysqld_multi log file version 2.16; run: 一 4月 2 15:12:44 2018 Stopping MySQL servers [root@hjx02 init.d]# mysqladmin: [Warning] Using a password on the command line interface can be insecure. 2018-04-02T07:12:46.467832Z mysqld_safe mysqld from pid file /alidata/mysql/data2/hjx02.pid2 ended [root@hjx02 init.d]# vi /etc/my.cnf [root@hjx02 init.d]# mysqld_multi --defaults-extra-file=/etc/my.cnf stop 3 WARNING: Log file disabled. Maybe directory or file isn't writable?
mysqld_multi log file version 2.16; run: 一 4月  2 15:15:54 2018

Stopping MySQL servers
[root@hjx02 init.d]# mysqladmin: [Warning] Using a password on the command line interface can be insecure.
2018-04-02T07:15:55.934832Z mysqld_safe mysqld from pid file /alidata/mysql/data3/hjx02.pid3 ended
```
