> 支持的MySQL数据库版本：5.5 5.6 5.7 8.0


# 常用健康检查

## 全表扫描的SQL

```
SELECT 
    *
FROM
    (SELECT 
        (DIGEST_TEXT) AS query, # SQL语句
            SCHEMA_NAME AS db, # 数据库
            IF(SUM_NO_GOOD_INDEX_USED > 0
                OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan, # 全表扫描总数
            COUNT_STAR AS exec_count, # 事件总计
            SUM_ERRORS AS err_count, # 错误总计
            SUM_WARNINGS AS warn_count, # 警告总计
            (SUM_TIMER_WAIT) AS total_latency, # 总的等待时间
            (MAX_TIMER_WAIT) AS max_latency, # 最大等待时间
            (AVG_TIMER_WAIT) AS avg_latency, # 平均等待时间
            (SUM_LOCK_TIME) AS lock_latency, # 锁时间总时长
            FORMAT(SUM_ROWS_SENT, 0) AS rows_sent, # 总返回行数
            ROUND(IFNULL(SUM_ROWS_SENT / NULLIF(COUNT_STAR, 0), 0)) AS rows_sent_avg, # 平均返回行数
            SUM_ROWS_EXAMINED AS rows_examined, # 总扫描行数
            ROUND(IFNULL(SUM_ROWS_EXAMINED / NULLIF(COUNT_STAR, 0), 0)) AS rows_examined_avg, # 平均扫描行数
            SUM_CREATED_TMP_TABLES AS tmp_tables, # 创建临时表的总数
            SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables, # 创建磁盘临时表的总数
            SUM_SORT_ROWS AS rows_sorted, # 排序总行数
            SUM_SORT_MERGE_PASSES AS sort_merge_passes, # 归并排序总行数
            DIGEST AS digest, # 对SQL_TEXT做MD5产生的32位字符串
            FIRST_SEEN AS first_seen, # 第一次执行时间
            LAST_SEEN AS last_seen # 最后一次执行时间
    FROM
        performance_schema.events_statements_summary_by_digest d) t1
WHERE
    t1.full_scan = '*'
ORDER BY t1.total_latency DESC
LIMIT 5;
```

## 创建大量临时表的SQL

```
SELECT 
    *
FROM
    (SELECT 
        (DIGEST_TEXT) AS query, # SQL语句
            SCHEMA_NAME AS db, # 数据库
            IF(SUM_NO_GOOD_INDEX_USED > 0
                OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan, # 全表扫描总数
            COUNT_STAR AS exec_count, # 事件总计
            SUM_ERRORS AS err_count, # 错误总计
            SUM_WARNINGS AS warn_count, # 警告总计
            (SUM_TIMER_WAIT) AS total_latency, # 总的等待时间
            (MAX_TIMER_WAIT) AS max_latency, # 最大等待时间
            (AVG_TIMER_WAIT) AS avg_latency, # 平均等待时间
            (SUM_LOCK_TIME) AS lock_latency, # 锁时间总时长
            FORMAT(SUM_ROWS_SENT, 0) AS rows_sent, # 总返回行数
            ROUND(IFNULL(SUM_ROWS_SENT / NULLIF(COUNT_STAR, 0), 0)) AS rows_sent_avg, # 平均返回行数
            SUM_ROWS_EXAMINED AS rows_examined, # 总扫描行数
            ROUND(IFNULL(SUM_ROWS_EXAMINED / NULLIF(COUNT_STAR, 0), 0)) AS rows_examined_avg, # 平均扫描行数
            SUM_CREATED_TMP_TABLES AS tmp_tables, # 创建临时表的总数
            SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables, # 创建磁盘临时表的总数
            SUM_SORT_ROWS AS rows_sorted, # 排序总行数
            SUM_SORT_MERGE_PASSES AS sort_merge_passes, # 归并排序总行数
            DIGEST AS digest, # 对SQL_TEXT做MD5产生的32位字符串
            FIRST_SEEN AS first_seen, # 第一次执行时间
            LAST_SEEN AS last_seen # 最后一次执行时间
    FROM
        performance_schema.events_statements_summary_by_digest d) t1
ORDER BY t1.tmp_disk_tables DESC
LIMIT 5;
```

## 大表(单表行数大于500w，且平均行长大于10KB)  

```
SELECT 
    t.table_name 表,
    t.table_schema 库,
    t.engine 引擎,
    t.table_length_B 表空间, #单位 Bytes
    t.table_length_B/t1.all_length_B 表空间占比,
    t.data_length_B 数据空间, #单位 Bytes
    t.index_length_B 索引空间, #单位 Bytes
    t.table_rows 行数,
    t.avg_row_length_B 平均行长KB
FROM
    (
    SELECT 
            table_name,
            table_schema,
            ENGINE,
            table_rows,
            data_length +  index_length AS table_length_B,
            data_length AS data_length_B,
            index_length AS index_length_B,
            AVG_ROW_LENGTH AS avg_row_length_B
    FROM
        information_schema.tables
    WHERE
        table_schema NOT IN ('mysql' , 'performance_schema', 'information_schema', 'sys')
        ) t
        join (
        select sum((data_length + index_length)) as all_length_B from information_schema.tables
        ) t1
WHERE
    t.table_rows > 5000000
        AND t.avg_row_length_B > 10240;
        
```

## 表碎片  

```
SELECT 
    table_schema, # 库
    table_name, # 表
    (index_length + data_length) total_length, # 表空间
    table_rows, # 行数
    data_length, # 数据空间 单位 Bytes
    index_length, # 索引空间 单位 Bytes
    data_free, # 空闲空间 单位 Bytes
    ROUND(data_free / (index_length + data_length),
            2) rate_data_free # 表碎片
FROM
    information_schema.tables
WHERE
    table_schema NOT IN ('information_schema' , 'mysql', 'performance_schema', 'sys')
ORDER BY rate_data_free DESC
LIMIT 5;
```

## 热点表  

```
SELECT 
    object_schema AS table_schema, # 库
    object_name AS table_name, # 表
    count_star AS rows_io_total, # 事件总数
    count_read AS rows_read, # read次数
    count_write AS rows_write, # write次数
    count_fetch AS rows_fetchs, # fetch次数
    count_insert AS rows_inserts, # insert次数
    count_update AS rows_updates, # update次数
    count_delete AS rows_deletes, # delete次数
    CONCAT(ROUND(sum_timer_fetch / 3600000000000000, 2),
            'h') AS fetch_latency, # fench总时间 单位 小时
    CONCAT(ROUND(sum_timer_insert / 3600000000000000, 2),
            'h') AS insert_latency, # insert总时间 单位 小时
    CONCAT(ROUND(sum_timer_update / 3600000000000000, 2),
            'h') AS update_latency, # update总时间 单位 小时
    CONCAT(ROUND(sum_timer_delete / 3600000000000000, 2),
            'h') AS delete_latency # delete总时间 单位 小时
FROM
    performance_schema.table_io_waits_summary_by_table
ORDER BY sum_timer_wait DESC
LIMIT 5;
```

## 全表扫描的表  

```
SELECT 
    object_schema, # 库
    object_name,  # 表
    count_read AS rows_full_scanned #全表扫描的行数
FROM
    performance_schema.table_io_waits_summary_by_index_usage
WHERE
    index_name IS NULL AND count_read > 0
ORDER BY count_read DESC
LIMIT 5;
```

## 未使用的索引  

```
SELECT 
    object_schema, # 库
    object_name, # 表
    index_name # 索引名
FROM
    performance_schema.table_io_waits_summary_by_index_usage
WHERE
    index_name IS NOT NULL
        AND count_star = 0
        AND object_schema NOT IN ('mysql' ,'performance_schema')
        AND index_name <> 'PRIMARY'
ORDER BY object_schema , object_name;
```

## 冗余索引



```
SELECT 
   a.TABLE_SCHEMA AS '数据名',
   a.TABLE_NAME AS '表名',
   group_concat(a.INDEX_NAME,b.INDEX_NAME) AS '重复索引',
   a.COLUMN_NAME AS '重复列名'
FROM
   information_schema.STATISTICS a
        JOIN
   information_schema.STATISTICS b ON a.TABLE_SCHEMA = b.TABLE_SCHEMA
        AND a.TABLE_NAME = b.TABLE_NAME
        AND a.SEQ_IN_INDEX = b.SEQ_IN_INDEX
        AND a.COLUMN_NAME = b.COLUMN_NAME
WHERE
   a.SEQ_IN_INDEX = 1
        AND a.INDEX_NAME <> b.INDEX_NAME group by a.TABLE_SCHEMA,a.TABLE_NAME,a.COLUMN_NAME;
```



## 库空间统计

```
SELECT 
    table_schema, # 库
    ROUND(SUM(data_length / 1024 / 1024), 2) AS data_length_MB, # 数据空间 单位MB
    ROUND(SUM(index_length / 1024 / 1024), 2) AS index_length_MB # 索引空间 单位MB
FROM
    information_schema.tables
GROUP BY table_schema
ORDER BY data_length_MB DESC , index_length_MB DESC;
```

## 表空间统计  

```
SELECT 
    t.table_name 表,
    t.table_schema 库,
    t.engine 引擎,
    t.table_length_B 表空间,
    t.table_length_B/t1.all_length_B 表空间占比,
    t.data_length_B 数据空间,
    t.index_length_B 索引空间,
    t.table_rows 行数,
    t.avg_row_length_B 平均行长KB
FROM
    (
    SELECT 
        table_name,
            table_schema,
            ENGINE,
            table_rows,
            data_length +  index_length AS table_length_B,
            data_length AS data_length_B,
            index_length AS index_length_B,
            AVG_ROW_LENGTH AS avg_row_length_B
    FROM
        information_schema.tables
    WHERE
        table_schema NOT IN ('mysql' , 'performance_schema', 'information_schema', 'sys')
        ) t
        join (
        select sum((data_length + index_length)) as all_length_B from information_schema.tables
        ) t1;
```

# 常用故障排查

##  查看有metalock锁的线程

```
SELECT 
   id, State, command
FROM
   information_schema.processlist
WHERE
   State = 'Waiting for table metadata lock';

```

## 创建MySQL事件-自动清理长时间执行的查询 

比如下面的代码会每 5 分钟清理一次当前用户运行时间超过 1 个小时且非锁等待会话。

```
delimiter //
create event my_long_running_query_monitor
on schedule every 5 minute
starts '2015-09-15 11:00:00'
on completion preserve enable do
begin
declare v_sql varchar(500);
declare no_more_long_running_query integer default 0;
declare c_tid cursor for
select concat ('kill ',id,';') from 
information_schema.processlist
where time >= 3600
and user = substring(current_user(),1,instr(current_user(),'@')-1)
and command not in ('sleep')
and state not like ('waiting for table%lock');
declare continue handler for not found
set no_more_long_running_query=1;
open c_tid;
repeat
fetch c_tid into v_sql;
set @v_sql=v_sql;
prepare stmt from @v_sql;
execute stmt;
deallocate prepare stmt;
until no_more_long_running_query end repeat;
close c_tid;
end;//
delimiter ;
```



## 查看InnoDB未提交的事务信息

```
SELECT 
   TIMEDIFF(SYSDATE(), trx_started) timediff,
   SYSDATE(),
   trx_started,
   id,
   USER,
   DB,
   COMMAND,
   STATE,
   trx_state,
   trx_query
FROM
   information_schema.processlist,
   information_schema.innodb_trx
WHERE
   trx_mysql_thread_id = id;
```

## 查看InnoDB事务锁冲突

```
SELECT 
   blocking_trx_id, COUNT(blocking_trx_id) AS countnum
FROM
   (SELECT 
       a.trx_id,
           a.trx_state,
           b.requesting_trx_id,
           b.blocking_trx_id
    FROM
       information_schema.innodb_lock_waits AS b
   LEFT JOIN information_schema.innodb_trx AS a ON a.trx_id = b.requesting_trx_id) AS t1
GROUP BY blocking_trx_id
ORDER BY countnum DESC;
```

## 获取到InnoDB事务锁冲突的原始id

```
SELECT 
   id
FROM
   information_schema.processlist,
   information_schema.innodb_trx
WHERE
   trx_mysql_thread_id = id
        AND trx_id IN (SELECT 
           blocking_trx_id
        FROM
           (SELECT 
               blocking_trx_id, COUNT(blocking_trx_id) AS countnum
            FROM
               (SELECT 
               a.trx_id,
                   a.trx_state,
                   b.requesting_trx_id,
                   b.blocking_trx_id
            FROM
               information_schema.innodb_lock_waits AS b
           LEFT JOIN information_schema.innodb_trx AS a ON a.trx_id = b.requesting_trx_id) AS t1
            GROUP BY blocking_trx_id
            ORDER BY countnum DESC
            LIMIT 1) c);
```



# MySQL Binglog

## 查看有metalock锁的线程

```
show master status;
```



## 查看当前二进制日志

```
show master status\G;
```

## 查看所有的binlog文件名和文件大小

```
show binary logs;
show master logs;
```

## 查看binlog日志中具体的事件

```
show binlog events in 'mastera.000005' from 219 limit 3;
```

# 字符集相关

## 查看支持的字符编码和校验集信息

```
show character set;
show character set like 'utf%';
show collation;
show collation like 'utf8%'
```

## 检查库的字符集和字符校验规则

```
SELECT DEFAULT_CHARACTER_SET_NAME, DEFAULT_COLLATION_NAME FROM information_schema.SCHEMATA S
WHERE schema_name = 'confluence_vpc'
AND 
(
DEFAULT_CHARACTER_SET_NAME != 'utf8'
OR
DEFAULT_COLLATION_NAME != 'utf8_bin'
);
```

## 检查表的字符集和字符校验规则

```
SELECT T.TABLE_NAME, C.CHARACTER_SET_NAME, C.COLLATION_NAME
FROM information_schema.TABLES AS T, information_schema.COLLATION_CHARACTER_SET_APPLICABILITY AS C
WHERE C.collation_name = T.table_collation
AND T.table_schema = 'confluence_vpc'
AND 
(
C.CHARACTER_SET_NAME != 'utf8'
OR
C.COLLATION_NAME != 'utf8_bin'
);
```

## 检查列的字符集和字符校验规则

```
SELECT TABLE_NAME, COLUMN_NAME, CHARACTER_SET_NAME, COLLATION_NAME
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'confluence_vpc' 
AND 
(
CHARACTER_SET_NAME != 'utf8'
OR
COLLATION_NAME != 'utf8_bin'
);
```

## 修改列的字符校验规则

```
SELECT CONCAT('ALTER TABLE `', table_name, '` MODIFY `', column_name, '` ', DATA_TYPE, '(', CHARACTER_MAXIMUM_LENGTH, ') CHARACTER SET UTF8 COLLATE utf8_bin', (CASE WHEN IS_NULLABLE = 'NO' THEN ' NOT NULL' ELSE '' END), ';')
FROM information_schema.COLUMNS 
WHERE TABLE_SCHEMA = 'confluence_vpc' 
AND 
(
CHARACTER_SET_NAME != 'utf8'
OR
COLLATION_NAME != 'utf8_bin'
);
```

# 会话查询

## 属于某个库的会话

```
select id from information_schema.processlist where db='ecshoptest'；
```

## 执行命令为sleep的会话

```
select id from information_schema.processlist where command='sleep'；
```

## 执行命令为query的会话

```
select id from information_schema.processlist where command='query'；
```

## 会话时间超过多少秒的的

```
select id from information_schema.processlist where time>5000;
```

## 找到某个库中事务状态为lock的会话id

```
select id from information_schema.processlist,information_schema.innodb_trx where trx_mysql_thread_id=id and trx_state like 'LOCK%' and db='ecshoptest';
```

## 所有的会话id

```
select id from information_schema.processlist；
```

## 属于某个用户的会话

```
select id from information_schema.processlist where user='yaoli'；
```
