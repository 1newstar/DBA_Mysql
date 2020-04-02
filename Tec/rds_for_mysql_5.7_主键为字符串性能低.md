# rds_for_mysql_5.7_主键为字符串性能低

## 故事背景

### 数据库明细

说在前面：

* 数据库：RDS For MySQL 5.7
* 实例规格：16核 / 64G
* 压测结果 `CPU 100% \ 活跃连接 33 / TPS 4/ QPS 1000`


### 故事情节

新业务做压侧，研发疑问：为什么一个简单的sql，也并非慢sql，在生产环境100个并发下，就把一个CSE系统的16C64G的RDS CPU压到100%了。

压测时间是3月27日 下午17:45 到17：55 。


### 剖析

<img src='https://i.loli.net/2020/04/02/7FKqRsWiEy49XAt.jpg' alt='7FKqRsWiEy49XAt'/>

<img src='https://i.loli.net/2020/04/02/LWxTvPnqh4m2ptl.jpg' alt='LWxTvPnqh4m2ptl'/>

<img src='https://i.loli.net/2020/04/02/OoxNDi4cmB2zqKI.jpg' alt='OoxNDi4cmB2zqKI'/>

<img src='https://i.loli.net/2020/04/02/g2HyAmlLn49RsWk.jpg' alt='g2HyAmlLn49RsWk'/>


从监控指标来看，16核64G的RDS，TPS不到1000，活跃连接数只有33，无慢SQL（运行超过1秒的SQL），该时间段执行时间最长执行次数最多的SQL语句执行计划正常（走复合索引，执行耗时min5ms，max260ms）。

导致慢的原因在哪里呢？

查询了一下实例审计日志，CPU 升高的时候主要是当时扫缓存逻辑读操作比较多消耗CPU 。当时实例主要innodb 查询扫描比较多。监控趋势增长完全一致

1. SQL 洞察查询  3月27日  下午17:45 到17：55 短时间的SQ了洞察日志可以看到，当时存在扫描行数多的语句（这个不是慢查询） 但是语句执行会扫描相对较多；

压测执行的sql 语句（已脱敏）：

```sql
SELECT r.id, r.transaction_no, r.package_code, r.premium_no, r.proposal_no , r.company_name, r.package_name, r.package_type, r.updated_date, r.calculation_mode , r.transfer_insurance_status
FROM table_1 r WHERE r.agent_id = 'abckjki10299384mcjki' AND r.agent_company_code = '0986' ORDER BY r.created_date DESC LIMIT 10
```

举例：

```sql
select type_key typeKey, code,cn_name value, description,value as dictValue,en_name enValue from table_2 where type_key='BO' and record_status = '1' order by sort

SELECT count(0) FROM table_3
```

2. 查询的表如果压测 最好表id 自增主键 使用int 类型的表压测，上边这个表id 主键是`varchar` 类型，您高并发的情况 **字符串主键的表** 性能相对没有 **int 数值型表**性能好。

### 优化建议

建议业务表加一个与业务无关的自增int 类型主键，提高数据库使用性能。

