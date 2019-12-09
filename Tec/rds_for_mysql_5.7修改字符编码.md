# 修改RDS For MySQL 5.7 字符集

## 修改库的字符编码和校验码，RDS控制台刷新后自动变更

```sql
ALTER DATABASE db1 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

# 修改表和列的字符集和校验码

```
ALTER TABLE t1 CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

# 批量生成变更语句

```sql
SELECT CONCAT('ALTER TABLE ', table_name, ' CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;')
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

# check

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

SELECT 
    table_schema,
    table_name,
    COLUMN_NAME,
    CHARACTER_SET_NAME,
    COLLATION_NAME
FROM
    information_schema.columns
WHERE
    table_schema = 'yourdb'
        AND (CHARACTER_SET_NAME != 'utf8mb4'
        OR COLLATION_NAME != 'utf8mb4_unicode_ci');
```


## 测试

```sql
mysql>CREATE TABLE t1(   
id int primary key auto_increment,    
uname  varchar(20) ,   
ucreatetime  datetime  ,   
age  int(11)) DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci;
执行成功，耗时：40 ms.
mysql>delimiter $$
sql分隔符设置为：[$$]
mysql>create  procedure test1()  
begin

declare v_cnt decimal (10)  default 0 ;
start transaction;
dd:loop            
        insert  into t1 values         
        (null,'用户1',sysdate(),20),         
        (null,'用户2',sysdate(),20),         
        (null,'用户3',sysdate(),20),         
        (null,'用户4',sysdate(),20),         
        (null,'用户5',sysdate(),20),         
        (null,'用户6',sysdate(),20),         
        (null,'用户7',sysdate(),20),         
        (null,'用户8',sysdate(),20),         
        (null,'用户9',sysdate(),20),         
        (null,'用户0',sysdate(),20)             
                ;                                        
        set v_cnt = v_cnt+10 ;                            
            if  v_cnt = 100000 then leave dd;                           
            end if;          
        end loop dd ; 
commit;
end
执行成功，耗时：4 ms.
mysql>delimiter ;
sql分隔符设置为：[;]
mysql>call test1();
执行成功，耗时：1532 ms.
mysql>call test1();
执行成功，耗时：1473 ms.
mysql>call test1();
执行成功，耗时：1553 ms.
mysql>show create table t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uname` varchar(20) DEFAULT NULL,
  `ucreatetime` datetime DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=300001 DEFAULT CHARSET=utf8
返回行数：[1]，耗时：4 ms.
mysql>ALTER DATABASE db1 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
执行成功，耗时：4 ms.
mysql>show create table t1\G;
*************************** 1. row ***************************
       Table: t1
Create Table: CREATE TABLE `t1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uname` varchar(20) DEFAULT NULL,
  `ucreatetime` datetime DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=300001 DEFAULT CHARSET=utf8
返回行数：[1]，耗时：4 ms.
mysql>create table t2 (id int primary key);
执行成功，耗时：5 ms.
mysql>show create table t2;
+-----------------+-----------------------------------------------------------------------------------------------------------+
| Table           | Create Table                                                                                              |
+-----------------+-----------------------------------------------------------------------------------------------------------+
| t2              | CREATE TABLE `t2` (
  `id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 |
+-----------------+-----------------------------------------------------------------------------------------------------------+
返回行数：[1]，耗时：4 ms.

mysql>ALTER TABLE t1 CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
执行成功，耗时：1198 ms.
mysql>show create table t1;
+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table           | Create Table                                                                                                                                                                                                                                            |
+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| t1              | CREATE TABLE `t1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uname` varchar(20) DEFAULT NULL,
  `ucreatetime` datetime DEFAULT NULL,
  `age` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=300001 DEFAULT CHARSET=utf8mb4 |
+-----------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
返回行数：[1]，耗时：4 ms.
mysql>show full fields from t1;
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
| Field           | Type           | Collation           | Null           | Key           | Default           | Extra           | Privileges                      | Comment           |
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
| id              | int(11)        |                     | NO             | PRI           |                   | auto_increment  | select,insert,update,references |                   |
| uname           | varchar(20)    | utf8mb4_general_ci  | YES            |               |                   |                 | select,insert,update,references |                   |
| ucreatetime     | datetime       |                     | YES            |               |                   |                 | select,insert,update,references |                   |
| age             | int(11)        |                     | YES            |               |                   |                 | select,insert,update,references |                   |
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
返回行数：[4]，耗时：4 ms.
mysql>create table t3 (id int primary key ,name varchar(244)) default charset utf8;
执行成功，耗时：6 ms.
mysql>show full fields from t3;
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
| Field           | Type           | Collation           | Null           | Key           | Default           | Extra           | Privileges                      | Comment           |
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
| id              | int(11)        |                     | NO             | PRI           |                   |                 | select,insert,update,references |                   |
| name            | varchar(244)   | utf8_general_ci     | YES            |               |                   |                 | select,insert,update,references |                   |
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
返回行数：[2]，耗时：5 ms.
mysql>alter table t3  CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
执行成功，耗时：8 ms.
mysql>show full fields from t3;
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
| Field           | Type           | Collation           | Null           | Key           | Default           | Extra           | Privileges                      | Comment           |
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
| id              | int(11)        |                     | NO             | PRI           |                   |                 | select,insert,update,references |                   |
| name            | varchar(244)   | utf8mb4_general_ci  | YES            |               |                   |                 | select,insert,update,references |                   |
+-----------------+----------------+---------------------+----------------+---------------+-------------------+-----------------+---------------------------------+-------------------+
返回行数：[2]，耗时：4 ms.
```

