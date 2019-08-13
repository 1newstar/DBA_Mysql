# percona toolkit

#### percona toolkit 简介

```
Percona Toolkit is a collection of advanced command-line tools used by Percona (http://www.percona.com/) support staff to perform a variety of MySQL and system tasks that are too difficult or complex to perform manually. 
These tools are ideal alternatives to private or “one-off” scripts because they are professionally developed, formally tested, and fully documented. They are also fully self-contained, so installation is quick and easy and no libraries are installed. 
Percona Toolkit is derived from Maatkit and Aspersa, two of the best-known toolkits for MySQL server administration. It is developed and supported by Percona. For more information and other free, open-source software developed by Percona, visit http://www.percona.com/software/.
```

Percona工具包文档Percona Toolkit是Percona（http://www.percona.com/） 支持人员使用的高级命令行工具的集合，用于执行各种MySQL和系统任务，这些任务太难或难以手动执行。这些工具是私有或“一次性”脚本的理想替代品，因为它们是专业开发，正式测试和完整记录的。它们也是完全独立的，因此安装快速简便，无需安装库。 
Percona Toolkit源自Maatkit和Aspersa，这两个最着名的MySQL服务器管理工​​具包。它由Percona开发和支持。有关Percona开发的更多信息和其他免费开源软件，请访问http://www.percona.com/software/。 

#### 在linux（centOS）上安装软件：yum install -y percona-toolkit

| 工具命令 | 工具作用                 | 备注                                          |
| -------- | ------------------------ | --------------------------------------------- |
| 开发类   | pt-duplicate-key-checker | 列出并删除重复的索引和外键                    |
|          | pt-online-schema-change  | 在线修改表结构                                |
|          | pt-query-advisor         | 分析查询语句，并给出建议，有bug 已废弃        |
|          | pt-show-grants           | 规范化和打印权限                              |
|          | pt-upgrade               | 在多个服务器上执行查询，并比较不同            |
| 性能类   | pt-index-usage           | 分析日志中索引使用情况，并出报告              |
|          | pt-pmp                   | 为查询结果跟踪，并汇总跟踪结果                |
|          | pt-visual-explain        | 格式化执行计划                                |
|          | pt-table-usage           | 分析日志中查询并分析表使用情况 pt 2.2新增命令 |
| 配置类   | pt-config-diff           | 比较配置文件和参数                            |
|          | pt-mysql-summary         | 对mysql配置和status进行汇总                   |
|          | pt-variable-advisor      | 分析参数，并提出建议                          |
| 监控类   | pt-deadlock-logger       | 提取和记录mysql死锁信息                       |
|          | pt-fk-error-logger       | 提取和记录外键信息                            |
|          | pt-mext                  | 并行查看status样本信息                        |
|          | pt-query-digest          | 分析查询日志，并产生报告 常用命令             |
|          | pt-trend                 | 按照时间段读取slow日志信息 已废弃             |
| 复制类   | pt-heartbeat             | 监控mysql复制延迟                             |
|          | pt-slave-delay           | 设定从落后主的时间                            |
|          | pt-slave-find            | 查找和打印所有mysql复制层级关系               |
|          | pt-slave-restart         | 监控salve错误，并尝试重启salve                |
|          | pt-table-checksum        | 校验主从复制一致性                            |
|          | pt-table-sync            | 高效同步表数据                                |
| 系统类   | pt-diskstats             | 查看系统磁盘状态                              |
|          | pt-fifo-split            | 拟切割文件并输出                              |
|          | pt-summary               | 收集和显示系统概况                            |
|          | pt-stalk                 | 出现问题时，收集诊断数据                      |
|          | pt-sift                  | 浏览由pt-stalk创建的文件 pt 2.2新增命令       |
|          | pt-ioprofile             | 查询进程IO并打印一个IO活动表 pt 2.2新增命令   |
| 实用类   | pt-archiver              | 将表数据归档到另一个表或文件中                |
|          | pt-find                  | 查找表并执行命令                              |
|          | pt-kill                  | Kill掉符合条件的sql 常用命令                  |
|          | pt-align                 | 对齐其他工具的输出 pt 2.2新增命令             |
|          | pt-fingerprint           | 将查询转成密文 pt 2.2新增命令                 |

汇总目录官方文档地址： 
https://www.percona.com/doc/percona-toolkit/2.2/index.html

#### 备注：基本所有涉及到数据库的操作，都需要填写相应的DNS命令，例如用户名，密码，数据库，数据库表等等。

## pt-align

#### pt-align [files]

将表的信息按列对齐打印输出。如果没有指定文件，则默认输出STDIN。

没有使用命令输出结果 
![这里写图片描述](https://img-blog.csdn.net/20180708162413141?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
使用命令输出结果 
![这里写图片描述](https://img-blog.csdn.net/20180708162555349?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
使用例子 
![这里写图片描述](https://img-blog.csdn.net/20180708162559923?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## pt-archiver

#### pt-archiver [OPTIONS] –source DSN –where WHERE

将数据库的表里的数据存储到另外一个表或者文件里。总而言之：就是用来归档数据。

作用： 
• 清理线上过期数据； 
• 导出线上数据，到线下数据作处理； 
• 清理过期数据，并把数据归档到本地归档表中，或者远端归档服务器。 
注意：pt-archiver操作的表必须有主键 
具体使用，从一张表导入到另外一张表，要注意的是新表必须是已经建立好的一样的表结构，不会自动创建表，而且where条件是必须指定的： 
![这里写图片描述](https://img-blog.csdn.net/20180708162622764?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![这里写图片描述](https://img-blog.csdn.net/20180708162634695?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)
![这里写图片描述](https://img-blog.csdn.net/20180708162642100?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
归档前的准备 
需要配置client字符集为utf-8,如果你用了utf-8的编码,防止归档数据为乱码

## pt-online-schema-change

#### pt-online-schema-change [OPTIONS] DNS

ALTER操作但是表没有锁定它们 
![这里写图片描述](https://img-blog.csdn.net/20180708162652141?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

##### pt-online-schema-change –alter “add column col int(11) Default null” h=host,P=3306,D=db,t=table,u=username,p=password –execute

参数说明： 
其中 –alter “add column col int(11) Default null” 为OPTIONS里面的内容，接下来是DNS的内容。 
D：数据库名 
t：数据库表名 
u：数据库登录用户名（可有可无，默认root） 
p：数据库密码（可有可无，默认没有密码） 
h：数据库地址（当使用远程连接的时候，本地的数据库IP必须被远程的数据库所允许请求连接）（可有可无，默认localhost） 
P：端口（可有可无，默认3306） 
-execute 表示执行该语句。 
PS: 
\1. 当参数有特殊符号的时候，使用’’(单引号)括起来。 
\2. OPTIONS中的””的命令内容无法使用多命令进行批操作。

## pt-config-diff

#### pt-config-diff [OPTIONS] CONFIG CONFIG [CONFIG…]

比较多份配置文件的不同

##### pt-config-diff h=host1 h=host2

比较2个地址中配置文件的不同

##### pt-config-diff /etc/my.cof h=host2

比较本地配置文件和远程配置文件的mysqld的不同

##### pt-config-diff /etc/my.cof /etc/wsk.cof

比较2个文件找那个mysqld的不同 
结果输出：

![这里写图片描述](https://img-blog.csdn.net/20180708162715795?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## pt-deadlock-logger

记录MySQL死锁的原因日志

#### pt-deadlock-logger [OPTIONS] DSN

##### pt-deadlock-logger h=host1

在host1上打印死锁的日志

##### pt-deadlock-logger h=host1 –iterations 1

在host1上打印死锁日志并退出

##### pt-deadlock-logger h=host1 –dest h=host2,D=percona_schema,t=deadlocks

将host1上的死锁信息打印到host2对应的数据库表中

## pt-diskstats

#### pt-diskstats

直接显示磁盘IO信息，与iostat类似，但是更详细。 
![这里写图片描述](https://img-blog.csdn.net/20180708162739315?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

实时循环显示数据结果

## pt-duplicate-key-checker

#### pt-duplicate-key-checker [OPTIONS] [DNS]

查找数据库中重复的索引和外键。

根据结果，我们可以看出重复的索引信息，包括索引定义，列的数据类型，以及修复建议。 
索引没有什么问题，如果有问题则会显示有问题的索引，并提供删除的sql语句 
没有问题： 
![这里写图片描述](https://img-blog.csdn.net/20180708162752175?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
存在重复索引

## pt-fifo-split

#### pt-fifo-split [OPTIONS] [FILE]

模拟切割文件，并通过管道传递给先入先出队列而不用真正的切割文件。

##### pt-fifo-split –lines 1000000 hugefile.txt

使用pt-fifo-split分割一个大文件，每次读1000000行

pt-fifo-split 默认会在/tmp下面建立一个fifo文件，并读取大文件中的数据写入到fifo文件，每次达到指定行数就往fifo文件中打印一个EOF字符，读取完成以后，关闭掉fifo文件并移走，然后重建fifo文件，打印更多的行。这样可以保证你每次读取的时候都能读取到制定的行数直到读取完成。注意此工具只能工作在类unix操作系统。

常用选项： 
–fifo /tmp/pt-fifo-split，指定fifo文件的路径； 
–offset 0，如果不打算从第一行开始读，可以设置这个参数； 
–lines 1000，每次读取的行数； 
–force，如果fifo文件已经存在，就先删除它，然后重新创建一个fifo文件；

## pt-find

#### pt-find [OPTIONS] [DATABASES]

查找MySQL中的表并执行操作，类似GUN的find命令。默认操作是打印数据库和表名。

##### pt-find –ctime +0 –engine InnoDB –password=sk.w1103

查找0天前所有用InnoDB创造的表并且打印出来 
![这里写图片描述](https://img-blog.csdn.net/20180708162811467?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

##### pt-find –engine InnoDB –exec “ALTER TABLE %D.%N ENGINE=MyISAM” –password=”” test

找到InnoDB格式的数据表，并将其转化为MyISAM格式 
![这里写图片描述](https://img-blog.csdn.net/20180708162829791?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

##### pt-find –tablesize +1k –password=sk.w1103 test

寻找数据库test中，大于5k的表，并打印出来 
![这里写图片描述](https://img-blog.csdn.net/20180708162834884?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

##### pt-find –printf “%T\t%D.%N\n” | sort -rn

找到所有表并打印它们的总数据和索引大小，并首先对最大的表进行排序 
![这里写图片描述](https://img-blog.csdn.net/20180708162842529?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70) 
![这里写图片描述](https://img-blog.csdn.net/20180708162922242?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## pt-summary

#### pt-summary

查看当前系统的信息 
![这里写图片描述](https://img-blog.csdn.net/20180708162935837?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## pt-heartbeat

#### pt-heartbeat [OPTIONS] [DSN] –update|–monitor|–check|–stop

监视MySQL的延迟操作

## pt-mysql-summary [OPTIONS]

查看当前MySQL的详细信息

##### pt-mysql-summary –p=sk.w1103

![这里写图片描述](https://img-blog.csdn.net/20180708162945157?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## pt-fk-error-logger

#### pt-fk-error-logger [OPTIONS] [DSN]

记录MySQL外键的错误信息

## pt-index-usage

#### pt-index-usage [OPTIONS] [FILES]

从日志中读取查询并分析它们如何使用索引

## pt-query-digest

#### pt-query-digest [OPTIONS] [FILES] [DSN]

从日志，进程列表和tcpdump分析MySQL查询

## pt-pmp

#### pt-pmp [OPTIONS] [FILES]

聚合所选程序的GDB堆栈跟踪

## pt-mext

#### pt-mext [OPTIONS] – COMMAND

查看MySQL 的SHOW GLOBAL STATUS的许多示例并排。

## pt-kill

#### pt-kill [OPTIONS] [DSN]

杀死符合特定条件的MySQL查询

##### pt-kill –busy-time 60 –kill

杀死查询时间大于60s的语句。

##### pt-kill –busy-time 60 –print

打印但是不杀死查询时间大于60s的语句。

##### pt-kill –match-command Sleep –kill –victims all –interval 10

每过10s检查并杀死睡眠状态的进程。

##### pt-kill –match-state login –print –victims all

打印但是不杀死所有进程。

常用参数说明 
• no-version-check：不最新检查版本 
• host：连接数据库的地址 
• port：连接数据库的端口 
• user：连接数据库的用户名 
• passowrd：连接数据库的密码 
• charset：指定字符集 
• match-command：指定杀死的查询类型 
• match-user：指定杀死的用户名,即杀死该用户的查询 
• busy-time：指定杀死超过多少秒的查询 
• kill：执行kill命令 
• victims：表示从匹配的结果中选择,类似SQL中的where部分,all是全部的查询 
• interal：每隔多少秒检查一次 
• print：把kill的查询打印出来

## pt-ioprofile

#### pt-ioprofile [OPTIONS] [FILE]

监视进程IO并打印文件表和I / O活动。

## pt-slave-find

#### pt-slave-find [OPTIONS] [DSN]

查找并打印MySQL从属的复制层次结构树。

## pt-show-grants

#### pt-show-grants [OPTIONS] [DSN]

规范化并打印MySQL授权，以便可以有效地复制，比较和版本控制它们。 
![这里写图片描述](https://img-blog.csdn.net/20180708163011293?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dzazExMDM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

## pt-show-grants –p=sk.w1103

```
打印MySQL的所有用户权限  
1
```

## pt-visual-explain

#### pt-visual-explain [OPTIONS] [FILES]

将EXPLAIN输出格式化为树。

## pt-variable-advisor

#### pt-variable-advisor [OPTIONS] [DSN]

分析MySQL变量并就可能出现的问题提出建议。

## pt-upgrade

#### pt-upgrade [OPTIONS] LOGS|RESULTS DSN [DSN]

验证查询结果在不同服务器上是否相同。

##### pt-upgrade h=host1 h=host2 slow.log

## pt-table-usage

#### pt-table-usage [OPTIONS] [FILES]

分析查询如何使用表。

## pt-table-sync

#### pt-table-sync [OPTIONS] DSN [DSN]

有效地同步MySQL表数据。使用对两个库不一致的数据进行同步，他能够自动发现两个实例间不一致的数据，然后进行sync操作，pt-table-sync无法同步表结构，和索引等对象，只能同步数据。

##### pt-table-sync –execute h=host1,D=db,t=tbl h=host2

同步数据库中表1到另外数据库的表1数据

##### pt-table-sync –execute host1 host2 host3

将host1上的所有表同步到host2和host3：

##### pt-table-sync –execute –sync-to-master slave1

使slave1具有与其复制主机相同的数据

##### pt-table-sync –execute –replicate test.checksum master1

解决test.checksum在master1的所有从站上发现的差异

##### pt-table-sync –execute –replicate test.checksum –sync-to-master slave1

与上面相同，但仅解决slave1上的差异

##### pt-table-sync –execute –sync-to-master h=master2,D=db,t=tbl

在master-master复制配置中同步master2

##### pt-table-sync –execute h=master1,D=db,t=tbl master2

同步所有库和表

##### pt-table-sync –charset=utf8 –ignore-databases=mysql,sys,percona u=root,p=root,h=host1,P=3306 u=root,p=root,h=host2,P=3306 –execute –print

忽略库 
–ignore-databases=指定要忽略的库

## pt-table-checksum

#### pt-table-checksum [OPTIONS] [DSN]

主要用来检查主从数据是否一致，

## pt-table-checksum

通过在主服务器上执行校验和查询来执行在线复制一致性检查，这会在与主服务器不一致的副本上生成不同的结果。可选DSN指定主主机。如果发现任何差异，或者发生任何警告或错误，则工具的“退出状态”不为零。以上命令将连接到localhost上的复制主机，每个表的校验和，并在每个检测到的副本上报告结果

## pt-stalk

#### pt-stalk [OPTIONS]

出现问题时收集有关MySQL的取证数据

## pt-slave-restart

#### pt-slave-restart [OPTIONS] [DSN]

在发生错误后，重启MySQL。

## pt-slave-delay

#### pt-slave-delay [OPTIONS] SLAVE_DSN [MASTER_DSN]

使从库的数据比主库的数据落后。

##### pt-slave-delay –delay 1m –interval 15s –run-time 10m slavehost

根据需要启动和停止从属服务器，使其落后于主服务器

## pt-sift

#### pt-sift FILE|PREFIX|DIRECTORY

浏览由pt-stalk创建的文件

## DSN

DSN的详细参数： 
a:查询 
A:字符集 
b：true代表禁用binlog 
D：数据库 
u：数据库链接账号 
p：数据库链接密码 
h：主机IP 
F：配置文件位置 
i：是否使用某索引 
m：插件模块 
P：端口号 
S：socket文件 
t：表

## OPTIONS

##### –ask-pass

连接数据库的时候提示密码

##### –charset

类型：string 
简写 –A 
字符类似设置

##### –config

类型：数组 
配置文件。如果该值为必须的情况下，必须放在命令首位（相当于default-file）。

##### –database

类型：string 
简写：-D 
连接数据库

##### –defaults-file

简写：-F 
类型：string 
仅从给定文件中读取mysql选项。必须提供绝对路径名。

##### –help

帮助并退出

##### –host

类型：string 
简写：-h 
连接地址

##### –[no]ignore-case

对比变量的时候忽略大小写。

##### –ignore-variables

类型：数组 
忽略，并不进行比较

##### –password

类型：string 
简写：-p 
连接密码

##### –port

类型：int 
简写：-P 
连接端口

##### –[no]report

将对比不同的报告写到磁盘中。

##### –socket

类型：string 
简写：-S 
套接字连接

##### –user

类型：string 
简写：-u 
用户名
