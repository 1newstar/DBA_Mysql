# RDS For MySQL 慢查询日志

1. 目前mysql.slow_log保存了从2017-4月开始到现在的所有慢日志，数据量大
2. 该表目前无索引
3. 按照query_time查询慢查询非常慢，直接报错

建议：
1. 阿里工单询问RDS5.7是否有参数控制该表的定期删除，例如只保留7天的慢查询(truncate mysql.user;)
2. 若阿里没有现成的配置，则自己写一个定时任务定期清理即可
3. 定期任务中远程连接RDS，执行一下命令



```shell


mysql> desc mysql.slow_log;
+----------------+---------------------+------+-----+----------------------+--------------------------------+
| Field          | Type                | Null | Key | Default              | Extra                          |
+----------------+---------------------+------+-----+----------------------+--------------------------------+
| start_time     | timestamp(6)        | NO   |     | CURRENT_TIMESTAMP(6) | on update CURRENT_TIMESTAMP(6) |
| user_host      | mediumtext          | NO   |     | NULL                 |                                |
| query_time     | time(6)             | NO   |     | NULL                 |                                |
| lock_time      | time(6)             | NO   |     | NULL                 |                                |
| rows_sent      | int(11)             | NO   |     | NULL                 |                                |
| rows_examined  | int(11)             | NO   |     | NULL                 |                                |
| db             | varchar(512)        | NO   |     | NULL                 |                                |
| last_insert_id | int(11)             | NO   |     | NULL                 |                                |
| insert_id      | int(11)             | NO   |     | NULL                 |                                |
| server_id      | int(10) unsigned    | NO   |     | NULL                 |                                |
| sql_text       | mediumblob          | NO   |     | NULL                 |                                |
| thread_id      | bigint(21) unsigned | NO   |     | NULL                 |                                |
+----------------+---------------------+------+-----+----------------------+--------------------------------+
12 rows in set (0.00 sec)

1. 设定定时任务
mysql -e "truncate mysql.slow_log"
```
