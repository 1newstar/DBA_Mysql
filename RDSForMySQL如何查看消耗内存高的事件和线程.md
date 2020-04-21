# 概述

本文介绍如何查看消耗内存高的事件和线程，为您解决内存相关问题提供参考。

# 操作步骤

## 将performance_schema参数值修改为ON

在左侧导航栏中单击 参数设置。

将performance_schema参数值修改为ON，如果已经为ON请忽略此步骤。

提示：该操作会重启实例，造成连接中断，重启前请做好业务安排，谨慎操作。

单击performance_schema参数右侧的修改按钮，将值修改为ON，然后单击 确定。

单击页面右上角 提交参数，等待实例重启完成即可。

## 打开内存监控

使用DMS或客户端连接MySQL实例，依次执行如下SQL语句，打开内存监控。

```SQL
update performance_schema.setup_instruments set enabled = 'yes' where name like 'memory%';
select * from performance_schema.setup_instruments where name like 'memory%innodb%' limit 5;
```

注：该命令是在线打开内存统计，所以只会统计打开后新增的内存对象，打开前的内存对象不会统计，建议您打开后等待一段时间再执行后续步骤，便于找出内存使用高的线程。
您可以参考如下SQL语句统计事件和线程的内存消耗量，并进行排序展示。

## 统计事件消耗内存

```SQL
select event_name,
       SUM_NUMBER_OF_BYTES_ALLOC
from performance_schema.memory_summary_global_by_event_name
order by SUM_NUMBER_OF_BYTES_ALLOC desc
LIMIT 10;
```

## 统计线程消耗内存

```SQL
select thread_id,
       event_name,
       SUM_NUMBER_OF_BYTES_ALLOC
from performance_schema.memory_summary_by_thread_by_event_name
order by SUM_NUMBER_OF_BYTES_ALLOC desc
limit 20;
```
系统显示类似如下。

## 查看详细的监控信息

您也可以参考如下SQL语句，查看详细的监控信息。

```SQL
select * from sys.x$memory_by_host_by_current_bytes;
select * from sys.x$memory_by_thread_by_current_bytes;
select * from sys.x$memory_by_user_by_current_bytes;
select * from sys.x$memory_global_by_current_bytes;
select * from sys.x$memory_global_total;
select * from performance_schema.memory_summary_by_account_by_event_name;
select * from performance_schema.memory_summary_by_host_by_event_name;
select * from performance_schema.memory_summary_by_thread_by_event_name;
select * from performance_schema.memory_summary_by_user_by_event_name;
select * from performance_schema.memory_summary_global_by_event_name;
select event_name,
       current_alloc
from sys.memory_global_by_current_bytes
where event_name like '%innodb%';
select event_name,current_alloc from sys.memory_global_by_current_bytes limit 5;
select m.thread_id tid,
       USER,
       esc.DIGEST_TEXT,
       total_allocated
FROM sys.memory_by_thread_by_current_bytes m,
     performance_schema.events_statements_current esc
WHERE m.`thread_id` = esc.THREAD_ID \G
```

找到问题事件或线程后，您可以排查业务代码和环境，解决内存高的问题。
