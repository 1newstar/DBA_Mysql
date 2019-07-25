# MySQL5.7_删除索引后不会立刻释放空间

```shell
root@MySQL-01 17:39:  [booboo]> system ls -lh /alidata/mysql/data/booboo
总用量 16M
-rw-r----- 1 mysql mysql   67 7月  25 17:09 db.opt
-rw-r----- 1 mysql mysql 8.5K 7月  25 17:38 t1.frm
-rw-r----- 1 mysql mysql  15M 7月  25 17:38 t1.ibd
root@MySQL-01 17:39:  [booboo]> optimize table t1;
+-----------+----------+----------+-------------------------------------------------------------------+
| Table     | Op       | Msg_type | Msg_text                                                          |
+-----------+----------+----------+-------------------------------------------------------------------+
| booboo.t1 | optimize | note     | Table does not support optimize, doing recreate + analyze instead |
| booboo.t1 | optimize | status   | OK                                                                |
+-----------+----------+----------+-------------------------------------------------------------------+
2 rows in set (1.09 sec)

root@MySQL-01 17:39:  [booboo]> system ls -lh /alidata/mysql/data/booboo
总用量 12M
-rw-r----- 1 mysql mysql   67 7月  25 17:09 db.opt
-rw-r----- 1 mysql mysql 8.5K 7月  25 17:39 t1.frm
-rw-r----- 1 mysql mysql  11M 7月  25 17:39 t1.ibd
```
