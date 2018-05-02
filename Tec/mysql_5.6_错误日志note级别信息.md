# mysql 5.6 错误日志中报错note级别

> 2018-04-03 

## 报错信息

```shell
2018-04-03 02:52:27	2018-04-01 05:39:13 36097 [Note] Multi-threaded slave statistics for channel '': seconds elapsed = 3756; events assigned = 164865; worker queues filled over overrun level = 0; waited due a Worker queue full = 0; waited due the total size = 0; slept when Workers occupied = 0
```

## 信息解释

Slave多线程并发重演提示信息：

* seconds elapsed = 3756; 上一次统计跟这一次统计的时间间隔为3756秒
* events assigned = 164865; 总共有164865个event被分配执行，计的是总数
* worker queues filled over overrun level = 0; 多线程同步中，worker 的私有队列长度超长的次数为0，计的是总数
* waited due a Worker queue full = 0; 因为worker的队列超长而产生等待的次数为0，计的是总数
* waited due the total size = 0; 超过最大size的次数为0
* slept when Workers occupied = 0 因为workder被占用而出现等待的总时间为0，总计值，单位是纳秒

## 源代码信息


通过源代码，找到下面一段，该段实现了上述日志的输出。

```shell
if ((my_now - rli->mts_last_online_stat)>=
mts_online_stat_period)
{
sql_print_information("Multi-threadedslave statistics%s: "
"seconds elapsed = %lu; "
"events assigned = %llu; "
"worker queues filled over overrun level = %lu;"
"waited due a Worker queue full = %lu; "
"waited due the total size = %lu; "
"waited at clock conflicts = %llu "
"waited(count) when Workers occupied = %lu "
"waited when Workers occupied = %llu",
rli->get_for_channel_str(),
static_cast
(my_now - rli->mts_last_online_stat),
rli->mts_events_assigned,
rli->mts_wq_overrun_cnt,
rli->mts_wq_overfill_cnt,
rli->wq_size_waits_cnt,
rli->mts_total_wait_overlap,
rli->mts_wq_no_underrun_cnt,
rli->mts_total_wait_worker_avail);
rli->mts_last_online_stat=my_now;
```
