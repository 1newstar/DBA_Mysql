# MySQL 5.7 主从复制设置为基于组的并发复制

[toc]

## 命令

```sql
-- 查看复制方式
select @@slave_parallel_type;
-- 停止sql进程
stop slave sql_thread;
-- 设置复制类型
set global slave_parallel_type='LOGICAL_CLOCK';
-- 查看系统cpu核数
system lscpu
-- 设置sql并发线程数
set global slave_parallel_workers=4;
-- 查看参数
select @@slave_parallel_type;
select @@slave_parallel_workers;
-- 查看slave线程运行明细
select thread_id,threads.name,sum(count_star) as totalCount, sum(sum_timer_wait) as TotalTime
from
performance_schema.events_waits_summary_by_thread_by_event_name
inner join performance_schema.threads using (thread_id)
where threads.name like 'thread/sql/slave\_%'
group by thread_id,threads.name;
```

## 执行过程

```bash
aliyun_root@MySQL-01 10:48:  [(none)]> select @@slave_parallel_type;
+-----------------------+
| @@slave_parallel_type |
+-----------------------+
| DATABASE              |
+-----------------------+
1 row in set (0.00 sec)

aliyun_root@MySQL-01 10:49:  [(none)]> set global.slave_parallel_type＝'LOGICAL_CLOCK';
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near ''LOGICAL_CLOCK'' at line 1
aliyun_root@MySQL-01 10:49:  [(none)]> set global slave_parallel_type='LOGICAL_CLOCK';
ERROR 3017 (HY000): This operation cannot be performed with a running slave sql thread; run STOP SLAVE SQL_THREAD first
aliyun_root@MySQL-01 10:49:  [(none)]> stop slave sql_thread;
Query OK, 0 rows affected (0.19 sec)

aliyun_root@MySQL-01 10:50:  [(none)]> set global slave_parallel_type='LOGICAL_CLOCK';
Query OK, 0 rows affected (0.00 sec)

aliyun_root@MySQL-01 10:50:  [(none)]> select @@slave_parallel_type;
+-----------------------+
| @@slave_parallel_type |
+-----------------------+
| LOGICAL_CLOCK         |
+-----------------------+
1 row in set (0.00 sec)

aliyun_root@MySQL-01 10:50:  [(none)]> select @@slave_parallel_workers;
+--------------------------+
| @@slave_parallel_workers |
+--------------------------+
|                        0 |
+--------------------------+
1 row in set (0.00 sec)

aliyun_root@MySQL-01 10:50:  [(none)]> system lscpu
Architecture:          x86_64
CPU 运行模式：    32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                4
On-line CPU(s) list:   0-3
每个核的线程数：1
每个座的核数：  4
Socket(s):             1
NUMA 节点：         1
厂商 ID：           GenuineIntel
CPU 系列：          6
型号：              62
Model name:            Intel(R) Xeon(R) CPU E5-2603 v2 @ 1.80GHz
步进：              4
CPU MHz：             1268.578
CPU max MHz:           1800.0000
CPU min MHz:           1200.0000
BogoMIPS:              3600.19
虚拟化：           VT-x
L1d 缓存：          32K
L1i 缓存：          32K
L2 缓存：           256K
L3 缓存：           10240K
NUMA node0 CPU(s):     0-3
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm tpr_shadow vnmi flexpriority ept vpid fsgsbase smep erms xsaveopt dtherm arat pln pts
aliyun_root@MySQL-01 10:50:  [(none)]> set global slave_parallel_workers=4;
Query OK, 0 rows affected (0.00 sec)

aliyun_root@MySQL-01 10:50:  [(none)]> select @@slave_parallel_workers;
+--------------------------+
| @@slave_parallel_workers |
+--------------------------+
|                        4 |
+--------------------------+
1 row in set (0.00 sec)

aliyun_root@MySQL-01 10:51:  [(none)]> select @@slave_parallel_type;
+-----------------------+
| @@slave_parallel_type |
+-----------------------+
| LOGICAL_CLOCK         |
+-----------------------+
1 row in set (0.00 sec)

aliyun_root@MySQL-01 10:51:  [(none)]> start slave sql_thread;
Query OK, 0 rows affected (0.15 sec)

aliyun_root@MySQL-01 10:51:  [(none)]> show global status like '%slave%';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| Com_show_slave_hosts   | 0     |
| Com_show_slave_status  | 3221  |
| Com_slave_start        | 2     |
| Com_slave_stop         | 2     |
| Slave_open_temp_tables | 0     |
+------------------------+-------+
5 rows in set (0.00 sec)

aliyun_root@MySQL-01 10:56:  [(none)]> select thread_id,threads.name,sum(count_star) as totalCount, sum(sum_timer_wait) as TotalTime
    -> from
    -> performance_schema.events_waits_summary_by_thread_by_event_name
    -> inner join performance_schema.threads using (thread_id)
    -> where threads.name like 'thread/sql/slave\_%'
    -> group by thread_id,threads.name;
+-----------+-------------------------+------------+------------------+
| thread_id | name                    | totalCount | TotalTime        |
+-----------+-------------------------+------------+------------------+
|        76 | thread/sql/slave_io     | 1120284464 | 2444251259480012 |
|      3276 | thread/sql/slave_sql    |    1082689 |  317202408257120 |
|      3277 | thread/sql/slave_worker |    3285486 |  321494886281772 |
|      3278 | thread/sql/slave_worker |    1970413 |  326551014191876 |
|      3279 | thread/sql/slave_worker |     208809 |  317975209383824 |
|      3280 | thread/sql/slave_worker |       5326 |  315940630825956 |
+-----------+-------------------------+------------+------------------+
```


## 加速从库重演

```sql
set global innodb_flush_log_at_trx_commit=0;
set global sync_binlog=0;
```

```bash
aliyun_root@MySQL-01 11:10:  [(none)]> set global innodb_flush_log_at_trx_commit=0;
Query OK, 0 rows affected (0.00 sec)

aliyun_root@MySQL-01 11:10:  [(none)]> set global sync_binlog=0;
Query OK, 0 rows affected (0.00 sec)

aliyun_root@MySQL-01 11:10:  [(none)]> show global variables like 'innodb_flush_log_at_trx_commit';
+--------------------------------+-------+
| Variable_name                  | Value |
+--------------------------------+-------+
| innodb_flush_log_at_trx_commit | 0     |
+--------------------------------+-------+
1 row in set (0.01 sec)

aliyun_root@MySQL-01 11:10:  [(none)]> show global variables like 'sync_binlog';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| sync_binlog   | 0     |
+---------------+-------+
1 row in set (0.00 sec)
```
