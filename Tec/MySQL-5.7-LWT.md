# MySQL 5.7 查看轻量级进程LWT

```sql
select a.thd_id,a.conn_id,a.user,a.db,a.command,a.pid,b.thread_id,b.processlist_id,b.thread_os_id from sys.processlist a join performance_schema.threads b on a.thd_id = b.thread_id;
```

```shell
ps -efLl|grep 18487
top -H
```

```shell
root@MySQL-01 17:26:  [(none)]> select a.thd_id,a.conn_id,a.user,a.db,a.command,a.pid,b.thread_id,b.processlist_id,b.thread_os_id from sys.processlist a join performance_schema.threads b on a.thd_id = b.thread_id;;
+--------+---------+---------------------------------+------+---------+-------+-----------+----------------+--------------+
| thd_id | conn_id | user                            | db   | command | pid   | thread_id | processlist_id | thread_os_id |
+--------+---------+---------------------------------+------+---------+-------+-----------+----------------+--------------+
|      1 |    NULL | sql/main                        | NULL | NULL    | NULL  |         1 |           NULL |        18180 |
|      2 |    NULL | sql/thread_timer_notifier       | NULL | NULL    | NULL  |         2 |           NULL |        18183 |
|      3 |    NULL | innodb/io_ibuf_thread           | NULL | NULL    | NULL  |         3 |           NULL |        18184 |
|      4 |    NULL | innodb/io_log_thread            | NULL | NULL    | NULL  |         4 |           NULL |        18185 |
|      5 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL  |         5 |           NULL |        18186 |
|      6 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL  |         6 |           NULL |        18187 |
|      7 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL  |         7 |           NULL |        18189 |
|      8 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL  |         8 |           NULL |        18190 |
|      9 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL  |         9 |           NULL |        18191 |
|     10 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL  |        10 |           NULL |        18193 |
|     11 |    NULL | innodb/page_cleaner_thread      | NULL | NULL    | NULL  |        11 |           NULL |        18202 |
|     12 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL  |        12 |           NULL |        18197 |
|     13 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL  |        13 |           NULL |        18199 |
|     14 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL  |        14 |           NULL |        18200 |
|     15 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL  |        15 |           NULL |        18192 |
|     16 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL  |        16 |           NULL |        18201 |
|     17 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL  |        17 |           NULL |        18194 |
|     18 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL  |        18 |           NULL |        18195 |
|     19 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL  |        19 |           NULL |        18196 |
|     20 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL  |        20 |           NULL |        18188 |
|     21 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL  |        21 |           NULL |        18198 |
|     23 |    NULL | innodb/srv_lock_timeout_thread  | NULL | NULL    | NULL  |        23 |           NULL |        18207 |
|     24 |    NULL | innodb/srv_error_monitor_thread | NULL | NULL    | NULL  |        24 |           NULL |        18208 |
|     25 |    NULL | innodb/srv_monitor_thread       | NULL | NULL    | NULL  |        25 |           NULL |        18209 |
|     26 |    NULL | innodb/srv_master_thread        | NULL | NULL    | NULL  |        26 |           NULL |        18210 |
|     27 |    NULL | innodb/srv_worker_thread        | NULL | NULL    | NULL  |        27 |           NULL |        18213 |
|     28 |    NULL | innodb/srv_purge_thread         | NULL | NULL    | NULL  |        28 |           NULL |        18211 |
|     29 |    NULL | innodb/srv_worker_thread        | NULL | NULL    | NULL  |        29 |           NULL |        18214 |
|     30 |    NULL | innodb/srv_worker_thread        | NULL | NULL    | NULL  |        30 |           NULL |        18212 |
|     31 |    NULL | innodb/buf_dump_thread          | NULL | NULL    | NULL  |        31 |           NULL |        18215 |
|     32 |    NULL | innodb/dict_stats_thread        | NULL | NULL    | NULL  |        32 |           NULL |        18216 |
|     33 |    NULL | sql/signal_handler              | NULL | NULL    | NULL  |        33 |           NULL |        18219 |
|     35 |       2 | sql/compress_gtid_table         | NULL | Daemon  | NULL  |        35 |              2 |        18221 |
|   2331 |    2298 | root@localhost                  | sys  | Query   | 15833 |      2331 |           2298 |        18487 |
+--------+---------+---------------------------------+------+---------+-------+-----------+----------------+--------------+
34 rows in set (0.05 sec)

ERROR: 
No query specified

root@MySQL-01 17:28:  [(none)]> select a.thd_id,a.conn_id,a.user,a.db,a.command,a.pid,b.thread_id,b.processlist_id,b.thread_os_id from sys.processlist a join performance_schema.threads b on a.thd_id = b.thread_id 
    -> where thread_os_id = 18487;
+--------+---------+----------------+------+---------+-------+-----------+----------------+--------------+
| thd_id | conn_id | user           | db   | command | pid   | thread_id | processlist_id | thread_os_id |
+--------+---------+----------------+------+---------+-------+-----------+----------------+--------------+
|   2331 |    2298 | root@localhost | sys  | Query   | 15833 |      2331 |           2298 |        18487 |
+--------+---------+----------------+------+---------+-------+-----------+----------------+--------------+
1 row in set (0.08 sec)

root@MySQL-01 17:29:  [(none)]> exit
Bye
[root@tick:/root]# ps -efLl|grep 18487
0 S root     16094 15741 16094  0    1  80   0 - 28181 pipe_w 17:29 pts/0    00:00:00 grep --color=auto 18487
1 S mysql    18180 16706 18487  0   40  80   0 - 1212178 futex_ 7月30 ?     00:02:31 /usr/local/mysql/bin/mysqld --basedir=/alidata/mysql --datadir=/alidata/mysql/data --plugin-dir=/alidata/mysql/lib/plugin --user=mysql --log-error=/alidata/mysql/data/dataerror.log --open-files-limit=65535 --pid-file=/alidata/mysql/data/MySQL-01.pid --socket=/tmp/mysql.sock --port=3306
```


## 5.6 无法直接查出轻量进程

