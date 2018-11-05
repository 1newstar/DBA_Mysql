# 在线删除MySQL大表

> 表量达到300G,生产环境中需要清空该表，降低对数据库的影响

## RDS

```shell
rename table tbname to test_tbname;
create table tbname like test_tbname;
drop table test_tbname;
```



## 自建MySQL

### 服务器使用XFS文件系统

如果是自建MySQL，且服务器使用文件系统为XFS则直接drop后新建即可；原因是xfs是字典更新，不做空间回收。

```shell
rename table tbname to test_tbname;
create table tbname like test_tbname;
drop table test_tbname;
```

### 保险做法

```shell
rename table tbname to test_tbname;
create table tbname like test_tbname;
#在建立了硬链接后再执行DROP TABLE操作
$ ln test_tbname.ibd test_tbname.ibd.hlink
drop table test_tbname;
for i in `seq 300 -1 1`;do truncate -s ${i}G test_tbname.ibd.hlink;sleep 3;done
rm -rf test_tbname.ibd.hlink;  
```

> 帮助文档：https://blog.csdn.net/haojianxiang/article/details/78531760

## 实际经验

```shell
abnormal_log_history20181025 这个表376G，没有索引
drop table abnormal_log_history20181025
执行成功，耗时：[10189ms.]﻿
```

