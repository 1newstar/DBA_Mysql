# TST-分表测试

> 2017-09-28 驻云DBA组

## 背景

* 用户（家族长）可以在页面查询精确到时分秒查询业绩汇总
* 该查询使用TST的分销系统数据库中的fx_achievement表，目前行数为1300万左右
* 目前查询正常速度在20~30秒
* 经常出现该查询事务阻塞的现象，并导致RDS CPU跑满

本测试尝试从分表的角度临时解决该问题

## 测试思路

1. 新建`fx_achievement_p`表，按照月分区
2. 导入数据，数据量为600w行
3. 测试查询并对比


## 测试过程

```shell
CREATE TABLE `fx_achievement_p` (
  `id` int(11) NOT NULL AUTO_INCREMENT ,
  `user_key` varchar(45) DEFAULT NULL,
  `card_level` varchar(1) DEFAULT NULL,
  `real_name` varchar(45) DEFAULT NULL,
  `yswf_code` varchar(32) NOT NULL,
  `order_no` varchar(50) NOT NULL,
  `sale` decimal(14,4) DEFAULT '0.0000',
  `pay_type` tinyint(1) DEFAULT NULL,
  `pay_order_no` varchar(50) DEFAULT NULL,
  `weid` varchar(50) DEFAULT NULL,
  `open_id` varchar(50) DEFAULT NULL,
  `pay_date` datetime ,
  `create_date` datetime DEFAULT NULL,
  `parent_code` varchar(32) DEFAULT NULL,
  `parent_name` varchar(45) DEFAULT NULL,
  `founder_code` varchar(32) DEFAULT NULL,
  `founder_name` varchar(45) DEFAULT NULL,
  `version` int(11) NOT NULL DEFAULT '0',
  `month` varchar(6) DEFAULT NULL,
  `quarter_code` varchar(32) DEFAULT NULL,
  `in_gas_station` tinyint(1) DEFAULT '0',
  `parent_in_gas_station` tinyint(1) DEFAULT '0',
  `parent_parent_code` varchar(32) DEFAULT NULL,
  `clearing` tinyint(1) DEFAULT '0',
  `clearing_date` datetime DEFAULT NULL,
  `exchange_rate` decimal(14,4) DEFAULT NULL,
  `orig_sale` decimal(14,4) DEFAULT NULL,
  `orig_currency` tinyint(1) DEFAULT NULL,
  `yswf_showtype` tinyint(1) DEFAULT NULL,
  `yswf_showtype_dt` int(11) DEFAULT NULL,
primary key (id,pay_date),
index (yswf_code,real_name),
index (founder_code,card_level)
) ENGINE=InnoDB AUTO_INCREMENT=13828002 DEFAULT CHARSET=utf8
PARTITION BY RANGE(TO_DAYS(pay_date))  
(PARTITION p1 VALUES LESS THAN (TO_DAYS('2016-12-01'))ENGINE = InnoDB,  
 PARTITION p2 VALUES LESS THAN (TO_DAYS('2017-01-01'))ENGINE = InnoDB,  
 PARTITION p3 VALUES LESS THAN (TO_DAYS('2017-02-01'))ENGINE = InnoDB,  
 PARTITION p4 VALUES LESS THAN (TO_DAYS('2017-03-01'))ENGINE = InnoDB,  
 PARTITION p5 VALUES LESS THAN (TO_DAYS('2017-04-01'))ENGINE = InnoDB,
 PARTITION pall VALUES LESS THAN maxvalue ENGINE = InnoDB);

# 导入数据
insert into fx_achievement_p select * from fx_achievement;

# 查询测试
SELECT achi.yswf_code, achi.real_name, COUNT(*), SUM(achi.sale)
FROM fx_achievement achi
WHERE 1 = 1
	AND achi.founder_code = 'AAZD'
	AND achi.card_level IN ('4', '5')
	AND achi.pay_date >= '2017-03-01 00:00:00'
	AND achi.pay_date < '2017-03-27 12:23:05'
GROUP BY achi.yswf_code, achi.real_name
LIMIT 10

SELECT achi.yswf_code, achi.real_name, COUNT(*), SUM(achi.sale)
FROM fx_achievement_p achi
WHERE 1 = 1
	AND achi.founder_code = 'AAZD'
	AND achi.card_level IN ('4', '5')
	AND achi.pay_date >= '2017-03-01 00:00:00'
	AND achi.pay_date < '2017-03-27 12:23:05'
GROUP BY achi.yswf_code, achi.real_name
LIMIT 10
测试时间对比为：0.030 0.010


select b.code,b.mobile,b.id_card,b.user_key,b.real_name,a.sale 
from 
(select user_key,sum(sale)'sale' 
from `fx_achievement` 
where 
pay_date > '2017-02-01' 
and pay_date <'2017-03-31'
group by user_key 
) as a  
join
(select a.user_key,a.code,concat(",",id_card)'id_card',mobile,real_name 
from 
fx_user as a 
join 
(
select `user_key` ,max(`create_date` )'create_date' 
from fx_user group by user_key 
)as b
on 
a.user_key =b.user_key 
and a.`create_date` =b.`create_date`  
and length(a.code)>4
)as b 
on a.user_key =b.user_key
order by sale DESC 
LIMIT 0,5000


select * from 
(select t1.code,t1.mobile,concat(",",id_card)'id_card',t1.user_key,t1.real_name,t2.sale 
from 
(select user_key,sum(sale)'sale' 
		from `fx_achievement` 
		where 
			pay_date > '2017-02-01' 
		and pay_date <'2017-03-31'
		group by user_key
	) as t2  
	join 
	fx_user as t1 
on t2.user_key =t1.user_key
and length(t1.code)>4
order by user_key,create_date desc 
) as t3
group by user_key
order by sale DESC
limit 0,5000
```








