## 前提

```sql
grant select on `mysql`.* to zyreport@'%' identified by 'Zyadmin@123';
grant select on `performance_schema`.* to zyreport@'%' identified by 'Zyadmin@123';
grant replication client on *.* to report@'%' identified by 'Zyadmin@123';
flush privileges;
```
如果是RDS，必须使用高权限账号进行授权。

# SQL质量

```sql
# Top CPU SQL
自建使用pt工具；云上使用api接口

# Top IO SQL	
自建使用pt工具；云上使用api接口


# 全表扫描SQL	
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

# 创建大量临时表的SQL	
SELECT 
    *
FROM
    (SELECT 
        (DIGEST_TEXT) AS query,
            SCHEMA_NAME AS db,
            IF(SUM_NO_GOOD_INDEX_USED > 0
                OR SUM_NO_INDEX_USED > 0, '*', '') AS full_scan,
            COUNT_STAR AS exec_count,
            SUM_ERRORS AS err_count,
            SUM_WARNINGS AS warn_count,
            (SUM_TIMER_WAIT) AS total_latency,
            (MAX_TIMER_WAIT) AS max_latency,
            (AVG_TIMER_WAIT) AS avg_latency,
            (SUM_LOCK_TIME) AS lock_latency,
            FORMAT(SUM_ROWS_SENT, 0) AS rows_sent,
            ROUND(IFNULL(SUM_ROWS_SENT / NULLIF(COUNT_STAR, 0), 0)) AS rows_sent_avg,
            SUM_ROWS_EXAMINED AS rows_examined,
            ROUND(IFNULL(SUM_ROWS_EXAMINED / NULLIF(COUNT_STAR, 0), 0)) AS rows_examined_avg,
            SUM_CREATED_TMP_TABLES AS tmp_tables,
            SUM_CREATED_TMP_DISK_TABLES AS tmp_disk_tables,
            SUM_SORT_ROWS AS rows_sorted,
            SUM_SORT_MERGE_PASSES AS sort_merge_passes,
            DIGEST AS digest,
            FIRST_SEEN AS first_seen,
            LAST_SEEN AS last_seen
    FROM
        performance_schema.events_statements_summary_by_digest d) t1
ORDER BY t1.tmp_disk_tables DESC
LIMIT 5;

# 大表(单表行数大于500w，且平均行长大于10KB)
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
        ) t1
WHERE
    t.table_rows > 5000000
        AND t.avg_row_length_B > 10240;
        
# 表碎片	

SELECT 
    table_schema,
    table_name,
    (index_length + data_length) total_length,
    table_rows,
    data_length,
    index_length,
    data_free,
    ROUND(data_free / (index_length + data_length),
            2) rate_data_free
FROM
    information_schema.tables
WHERE
    table_schema NOT IN ('information_schema' , 'mysql', 'performance_schema', 'sys')
ORDER BY rate_data_free DESC
LIMIT 5;


# 热点表	
SELECT 
    object_schema AS table_schema,
    object_name AS table_name,
    count_star AS rows_io_total,
    count_read AS rows_read,
    count_write AS rows_write,
    count_fetch AS rows_fetchs,
    count_insert AS rows_inserts,
    count_update AS rows_updates,
    count_delete AS rows_deletes,
    CONCAT(ROUND(sum_timer_fetch / 3600000000000000, 2),
            'h') AS fetch_latency,
    CONCAT(ROUND(sum_timer_insert / 3600000000000000, 2),
            'h') AS insert_latency,
    CONCAT(ROUND(sum_timer_update / 3600000000000000, 2),
            'h') AS update_latency,
    CONCAT(ROUND(sum_timer_delete / 3600000000000000, 2),
            'h') AS delete_latency
FROM
    performance_schema.table_io_waits_summary_by_table
ORDER BY sum_timer_wait DESC
LIMIT 5;

# 全表扫描的表	
SELECT 
    object_schema, object_name, count_read AS rows_full_scanned
FROM
    performance_schema.table_io_waits_summary_by_index_usage
WHERE
    index_name IS NULL AND count_read > 0
ORDER BY count_read DESC
LIMIT 5;

# 未使用的索引	
SELECT 
    object_schema, object_name, index_name
FROM
    performance_schema.table_io_waits_summary_by_index_usage
WHERE
    index_name IS NOT NULL
        AND count_star = 0
        AND object_schema NOT IN ('mysql' ,'performance_schema')
        AND index_name <> 'PRIMARY'
ORDER BY object_schema , object_name;

# 冗余索引
SELECT 
    a.TABLE_SCHEMA AS '数据名',
    a.TABLE_NAME AS '表名',
    a.INDEX_NAME AS '索引1',
    b.INDEX_NAME AS '索引2',
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
        AND a.INDEX_NAME <> b.INDEX_NAME;
```

# 空间统计

```sql
# 库空间
SELECT 
    table_schema,
    ROUND(SUM(data_length / 1024 / 1024), 2) AS data_length_MB,
    ROUND(SUM(index_length / 1024 / 1024), 2) AS index_length_MB
FROM
    information_schema.tables
GROUP BY table_schema
ORDER BY data_length_MB DESC , index_length_MB DESC;

# 表空间
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
        ) t1
```


