## 命令准备

### 查看指定数据库字符集明细

```sql
SELECT table_name, CHARACTER_SET_NAME,COLLATION_NAME
FROM information_schema.TABLES AS T, information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` AS C
WHERE C.collation_name = T.table_collation
AND T.table_schema = 'yourdb'
AND
(
C.CHARACTER_SET_NAME != 'utf8mb4'
OR
C.COLLATION_NAME != 'utf8mb4_unicode_ci'
);
```

### 生成修改字符集的命令

```sql
SELECT CONCAT('ALTER TABLE ', table_name, ' CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
FROM information_schema.TABLES AS T, information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` AS C
WHERE C.collation_name = T.table_collation
AND T.table_schema = 'ecshoptest'
AND
(
 C.CHARACTER_SET_NAME != 'utf8mb4'
 OR
 C.COLLATION_NAME != 'utf8mb4_unicode_ci'
);
```

## 参考

[confluence业务](https://confluence.atlassian.com/kb/how-to-fix-the-collation-and-character-set-of-a-mysql-database-744326173.html?spm=a2c4e.10696291.0.0.d80619a4Csljrv)
