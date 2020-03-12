```sql
# 生成删除索引的SQL
SELECT
    concat(
    'alter table `',
    table_schema,
    '`.`',
    table_name,
    '` drop index `',
    index_name,
    '`;'
    )
FROM
    information_schema.STATISTICS
    where index_name != 'PRIMARY' and table_schema in ('xx','xx2')
GROUP BY table_schema , table_name , index_type, index_name;

SELECT 
    concat(
    'alter table `', 
    table_schema,
    '`.`',
    table_name,
    '` add ',
    case when NON_UNIQUE=0 then 'UNIQUE'
	else '' end,
    ' index `',
	index_name,
    '` (',
    GROUP_CONCAT(concat('`',column_name,'`')),
    ');'
    )
FROM
    information_schema.STATISTICS
    where index_name != 'PRIMARY' and table_schema in ('xx','xx2')
GROUP BY table_schema , table_name , index_type, index_name;

# 如何保证复合索引的列顺序？
# GROUP_CONCAT(column_name) 时，按照默认顺序连接，而STATISTICS表中 SEQ_IN_INDEX 记录的信息可以了解到数据库已按照先后顺序排列，因此不用担心乱序。
# 如何确定是 UNIQUE 还是 非 unique 索引？
# 通过 NON_UNIQUE=0 判断
```

测试结果
```sql
| concat(
    'alter table `',
    table_schema,
    '`.`',
    table_name,
    '` add ',
    case when NON_UNIQUE=0 then 'UNIQUE'
    else '' end,
    ' index `',
    index_name,
    '` (',
    GROUP_CONCAT(concat('`',column_name,'`')),
    ');'
    ) |
+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| alter table `test01`.`t1` add UNIQUE index `new2` (`new2`);                                                                                                                                                                                                 |
| alter table `test01`.`t1` add  index `idx_h` (`hana`);                                                                                                                                                                                                      |
| alter table `test01`.`t1` add  index `idx_s` (`stock`);                                                                                                                                                                                                     |
+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
3 rows in set (0.00 sec)
```

对比索引

```sql
# 检查主键是否一致
SELECT
table_schema 库名, table_name 表名, index_name 索引名称, index_type 索引类型,NON_UNIQUE 是否唯一,
GROUP_CONCAT(column_name) 索引使用的列
FROM
information_schema.STATISTICS
where index_name = 'PRIMARY'  and table_schema not in ('mysql','information_schema')
GROUP BY table_schema , table_name , index_type, index_name,NON_UNIQUE;
 
 
# 检查非主键是否一致
SELECT
table_schema 库名, table_name 表名, index_name 索引名称, index_type 索引类型,NON_UNIQUE 是否唯一,
GROUP_CONCAT(column_name) 索引使用的列
FROM
information_schema.STATISTICS
where index_name = 'PRIMARY' and table_schema not in ('mysql','information_schema')
GROUP BY table_schema , table_name , index_type, index_name,NON_UNIQUE;
```
