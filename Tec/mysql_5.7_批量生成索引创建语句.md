```sql
SELECT 
    concat(
    'alter talbe ', 
    table_schema,
    '.',
    table_name,
    ' add ',
    index_type,
    ' index ',
	index_name,
    ' (',
    GROUP_CONCAT(column_name),
    ');'
    )
FROM
    information_schema.STATISTICS
    where index_name != 'PRIMARY' and table_schema in ('xx','xx2')
GROUP BY table_schema , table_name , index_type, index_name;

# 如何保证复合索引的列顺序？
# GROUP_CONCAT(column_name) 时，按照默认顺序连接，而STATISTICS表中 SEQ_IN_INDEX 记录的信息可以了解到数据库已按照先后顺序排列，因此不用担心乱序。
```


对比索引

```sql
SELECT 
table_schema 库名, table_name 表名,  index_name 索引名称, index_type 索引类型,
    GROUP_CONCAT(column_name) 索引使用的列
FROM
    information_schema.STATISTICS
    where index_name != 'PRIMARY'   and table_schema='xteppdb'
GROUP BY table_schema , table_name , index_type, index_name;
```
