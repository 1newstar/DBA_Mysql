# Fio压测磁盘

> 2018-07-24 大宝

[TOC]

## 安装fio

CentOS `yum` 源自带`fio`软件，直接yum安装：

```shell
[root@sh_02 ~]# yum install -y fio
```

## 压测实例

```shell
[root@sh_02 ~]# fio -filename=/dev/vda1 -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=300 -group_reporting -name=mytest
mytest: (g=0): rw=randread, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=psync, iodepth=1
...
fio-3.1
Starting 10 threads
Jobs: 6 (f=6): [r(1),_(2),r(3),_(2),r(2)][100.0%][r=2197MiB/s,w=0KiB/s][r=141k,w=0 IOPS][eta 00m:00s]
mytest: (groupid=0, jobs=10): err= 0: pid=15256: Tue Jul 24 11:22:45 2018
   read: IOPS=119k, BW=1854MiB/s (1944MB/s)(20.0GiB/11049msec)
    clat (usec): min=14, max=73003, avg=81.48, stdev=236.43
     lat (usec): min=14, max=73003, avg=81.88, stdev=236.45
    clat percentiles (usec):
     |  1.00th=[   25],  5.00th=[   40], 10.00th=[   47], 20.00th=[   53],
     | 30.00th=[   58], 40.00th=[   61], 50.00th=[   64], 60.00th=[   67],
     | 70.00th=[   71], 80.00th=[   77], 90.00th=[   92], 95.00th=[  119],
     | 99.00th=[  515], 99.50th=[  873], 99.90th=[ 2212], 99.95th=[ 3326],
     | 99.99th=[ 6521]
   bw (  KiB/s): min=27831, max=244672, per=10.03%, avg=190396.69, stdev=64486.41, samples=213
   iops        : min= 1739, max=15292, avg=11899.65, stdev=4030.47, samples=213
  lat (usec)   : 20=0.36%, 50=14.61%, 100=77.75%, 250=5.21%, 500=1.04%
  lat (usec)   : 750=0.39%, 1000=0.24%
  lat (msec)   : 2=0.28%, 4=0.09%, 10=0.03%, 20=0.01%, 50=0.01%
  lat (msec)   : 100=0.01%
  cpu          : usr=1.90%, sys=7.43%, ctx=1310606, majf=0, minf=47
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwt: total=1310720,0,0, short=0,0,0, dropped=0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: bw=1854MiB/s (1944MB/s), 1854MiB/s-1854MiB/s (1944MB/s-1944MB/s), io=20.0GiB (21.5GB), run=11049-11049msec

Disk stats (read/write):
  vda: ios=1299933/5, merge=0/0, ticks=83015/4, in_queue=82966, util=97.92%
```

## 命令明细

```shell
fio -filename=/dev/vda1 -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=2G -numjobs=10 -runtime=300 -group_reporting -name=mytest
```

说明：
|参数|解释|
|:--|:--|
|filename=/dev/vda1 |      测试文件名称，通常选择需要测试的盘的data目录。|
|direct=1   |              测试过程绕过机器自带的buffer。使测试结果更真实。|
|rw=randwrite   |          测试随机写的I/O|
|rw=randrw     |           测试随机写和读的I/O|
|bs=16k          |         单次io的块文件大小为16k|
|bsrange=512-2048   |      同上，提定数据块的大小范围|
|size=5g   | 本次的测试文件大小为5g，以每次4k的io进行测试。|
|numjobs=30      |         本次的测试线程为30.|
|runtime=1000   |          测试时间为1000秒，如果不写则一直将5g文件分4k每次写完为止。|
|ioengine=psync  |         io引擎使用pync方式|
|rwmixwrite=30    |        在混合读写的模式下，写占30%|
|group_reporting    |      关于显示结果的，汇总每个进程的信息。|
|lockmem=1g          |     只使用1g内存进行测试。|
|zero_buffers          |   用0初始化系统buffer。|
|nrfiles=8               | 每个进程生成文件的数量。|

## 压测解读

```shell

```

