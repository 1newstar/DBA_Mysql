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
