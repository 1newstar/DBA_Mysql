# 应用场景

> 2019-07-31

异地三中心：美国-中国-欧洲

## 结论

3个地域3个实例，实现多主同步，需要创建三个双向同步链路。可以满足需求。

## 测试过程


库名：
`qinxi`

不同地域不同实例：

* A: rm-bp132o888i2azu8qn  华东1（杭州）可用区H
* B：rm-uf6qv3d018nlh1pg8  华东2（上海）可用区G
* C：rm-m5e98a63pd23435k1  华北1（青岛）可用区B


需要创建三个双向同步链路：

```shell
A——B 双向
B——C 双向
C——A 双向
```

注：每个同步任务显示在目标实例的地域中


A实例创建t1表： 并同步至B实例和C实例

```sql
CREATE TABLE `t1` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(32) NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci;
```

C实例t1表插入一条记录:并通过至A实例和C实例

```sql
INSERT INTO t1 (id,name) VALUES(7,'lll');
```

B实例创建t2表：并同步至A实例和C实例

```sql
CREATE TABLE `t2` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`name` varchar(32) NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci;
```

**结论：阿里的RDS支持，三点多主同步。**
