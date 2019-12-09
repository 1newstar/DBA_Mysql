```sql
SELECT 
    concat(
    'alter talbe ', 
    table_schema,
    '.',
    table_name,
    ' add ',
    index_type,
    ' index',
    ' (',
    GROUP_CONCAT(column_name),
    ');'
    )
FROM
    information_schema.STATISTICS
    where index_name != 'PRIMARY'   
GROUP BY table_schema , table_name , index_type, index_name;
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
