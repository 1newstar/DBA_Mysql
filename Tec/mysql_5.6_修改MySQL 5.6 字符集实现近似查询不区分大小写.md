# 自建MySQL5.6实现近似查询不区分大小写

> 2020.03.13 BoobooWei

[`lower_case_table_names`](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_lower_case_table_names)

# 解决方法

修改MySQL 5.6 字符集

## 测试语句

```sql
show variables like '%lower%';
select DESCRIPTION from isp_maindb_n.sys_userinfo where DESCRIPTION like 'CHO%';
select DESCRIPTION from isp_maindb_n.sys_userinfo where DESCRIPTION like 'cho%';
ALTER TABLE isp_maindb_n.sys_userinfo CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE isp_maindb_s.sys_userinfo CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;
```

## 批量修改

**准备全库修改语句** Collapse source

```sql
ALTER DATABASE <xxx> CHARACTER SET utf8 COLLATE utf8_general_ci;
 
 
SELECT CONCAT('ALTER TABLE ', table_name, ' CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;')
FROM information_schema.TABLES AS T, information_schema.`COLLATION_CHARACTER_SET_APPLICABILITY` AS C
WHERE C.collation_name = T.table_collation
AND T.table_schema = '<xxx>'
AND
(
 C.CHARACTER_SET_NAME != 'utf8'
 OR
 C.COLLATION_NAME != 'utf8_unicode_ci'
);
 
--check
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
        AND (CHARACTER_SET_NAME != 'utf8'
        OR COLLATION_NAME != 'utf8_unicode_ci');
```



# 测试过程

Linux 自建MySQL `lower_case_table_names`： 此参数不可以动态修改，必须重启数据库

* `lower_case_table_names = 1`  表名存储在磁盘是小写的，但是比较的时候是不区分大小写
* `lower_case_table_names=0`  表名存储为给定的大小和比较是区分大小写的 

```sql
mysql> show variables like '%lower%';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| lower_case_file_system | OFF   |
| lower_case_table_names | 1     |
+------------------------+-------+
2 rows in set (0.00 sec)
 
 
mysql> select DESCRIPTION from isp_maindb_n.sys_userinfo where DESCRIPTION like 'CHO%';
+------------------------------+
| DESCRIPTION                  |
+------------------------------+
| CHO Agency Admin   louren
   |
| CHO Agency Admin   terry
    |
| CHO Agency Admin   eddy
     |
| CHO Agency Admin   bona
     |
| CHO Agency Admin  sonja
     |
| CHO Agency Admin    cynthia
 |
| CHO Agency Admin  tiger
     |
| CHO Agency Admin
            |
| CHO Agency Admin  alan
      |
| CHO Agency Admin   jacky
    |
| CHO Agency Admin   lilian
   |
| CHO  simon                   |
| CHO RR                       |
+------------------------------+
13 rows in set (0.04 sec)
 
mysql> select DESCRIPTION from isp_maindb_n.sys_userinfo where DESCRIPTION like 'cho%';
+--------------+
| DESCRIPTION  |
+--------------+
| cho  dephone |
| cho kitty    |
| cho  perry   |
| cho george   |
| cho  judy    |
+--------------+
5 rows in set (0.04 sec)
 
mysql> show create table isp_maindb_n.sys_userinfo\G;
*************************** 1. row ***************************
       Table: sys_userinfo
Create Table: CREATE TABLE `sys_userinfo` (
  `USERID` bigint(20) NOT NULL,
  `ACCOUNT` varchar(32) COLLATE utf8_bin DEFAULT NULL,
  `ACCOUNTTYPE` varchar(1) COLLATE utf8_bin DEFAULT NULL,
  `USERTYPE` varchar(1) COLLATE utf8_bin DEFAULT NULL,
  `USERNAME` varchar(250) COLLATE utf8_bin DEFAULT NULL,
  `PHONE` varchar(16) COLLATE utf8_bin DEFAULT NULL,
  `DEPTID` varchar(16) COLLATE utf8_bin DEFAULT NULL,
  `CITYID` varchar(18) COLLATE utf8_bin DEFAULT NULL,
  `COMPANYCODE` varchar(8) COLLATE utf8_bin DEFAULT NULL,
  `OFFICEID` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `AGENCY` varchar(32) COLLATE utf8_bin DEFAULT NULL,
  `EMAIL` varchar(32) COLLATE utf8_bin DEFAULT NULL,
  `VALIDATE` datetime DEFAULT NULL,
  `SEX` varchar(1) COLLATE utf8_bin DEFAULT NULL,
  `DESCRIPTION` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `ACCOUNTNONEXPIRED` int(11) DEFAULT NULL,
  `ACCOUNTNONLOCKED` int(11) DEFAULT NULL,
  `CREDENTIALSNONEXPIRED` int(11) DEFAULT NULL,
  `ENABLED` int(11) DEFAULT NULL,
  `SOURCE` varchar(1) COLLATE utf8_bin DEFAULT NULL,
  `LOCKDATE` datetime DEFAULT NULL,
  `LASTTIME` datetime DEFAULT NULL,
  `TIMES` bigint(20) DEFAULT NULL,
  `JSONDATA` text COLLATE utf8_bin,
  `PWDCHANGEDATE` datetime DEFAULT NULL,
  `INITIME` int(11) DEFAULT NULL,
  `CHANNEL` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `PWDID` varchar(32) COLLATE utf8_bin DEFAULT NULL,
  `GENDATE` datetime DEFAULT NULL,
  `RECENTDATE` datetime DEFAULT NULL,
  `CHANNELKEY` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `PASSWORD` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `AESPASSWORD` varchar(200) COLLATE utf8_bin DEFAULT NULL,
  `INSERTIME` datetime DEFAULT NULL,
  `UPDATETIME` datetime DEFAULT NULL,
  `SRCSYS` varchar(10) COLLATE utf8_bin DEFAULT NULL,
  `DTL__CAPXRESTART1` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `DTL__CAPXRESTART2` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `DTL__CAPXUOW` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `DTL__CAPXUSER` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `DTL__CAPXTIMESTAMP` varchar(20) COLLATE utf8_bin DEFAULT NULL,
  `DTL__CAPXACTION` varchar(1) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`USERID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
 
 
mysql> show table status like "sys_userinfo"\G;
*************************** 1. row ***************************
           Name: sys_userinfo
         Engine: InnoDB
        Version: 10
     Row_format: Compact
           Rows: 97754
 Avg_row_length: 435
    Data_length: 42565632
Max_data_length: 0
   Index_length: 0
      Data_free: 8388608
 Auto_increment: NULL
    Create_time: 2019-11-15 11:27:13
    Update_time: NULL
     Check_time: NULL
      Collation: utf8_general_ci
       Checksum: NULL
 Create_options:
        Comment:
1 row in set (0.00 sec)
```
