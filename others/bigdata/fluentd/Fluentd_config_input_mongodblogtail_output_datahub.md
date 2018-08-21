# td-agentd

```shell
curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent3.sh | sh
systemctl start td-agent.service
curl -X POST -d 'json={"json":"message"}' http://localhost:8888/debug.test
tail -f /var/log/td-agent/td-agent.log
```

# ruby和gem

```shell
cd /alidata/install/
wget wget https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.0-preview1.tar.gz
tar -xf ruby-2.6.0-preview1.tar.gz 
cd ruby-2.6.0-preview1
./configure
make && make install
ruby -v
gem -v
cd ext/openssl/
 ruby extconf.rb --with-openssl-include=/usr/include/openssl/
gem source -l
gem source -r https://rubygems.org/
gem source -a https://gems.ruby-china.org/

```

# 插件 fluent-plugin-datahub

```shell
gem install fluent-plugin-datahub
```

# 插件fluent-plugin-grok-parser

```shell
gem install fluent-plugin-grok-parser
```

# 查看所有安装的gem包
```shell
[root@sh_02 openssl]# gem list

*** LOCAL GEMS ***

bigdecimal (1.2.8)
cool.io (1.5.3)
did_you_mean (1.0.0)
dig_rb (1.0.1)
fluent-plugin-datahub (0.12.25)
fluent-plugin-grok-parser (2.1.6)
fluentd (1.2.4)
http_parser.rb (0.6.0)
io-console (0.4.5)
json (1.8.3.1)
minitest (5.8.5)
msgpack (1.2.4)
net-telnet (0.1.1)
power_assert (0.2.6)
psych (2.1.0.1)
rake (10.4.2)
rdoc (4.2.1)
serverengine (2.0.7)
sigdump (0.2.4)
strptime (0.2.3)
test-unit (3.1.5)
thread_safe (0.3.6)
tzinfo (1.2.5)
tzinfo-data (1.2018.5)
yajl-ruby (1.4.1)

```

# mongodb的匹配



```shell
2018-08-01T22:00:31.367+0800 I COMMAND  [conn4986471] command omdmain.item_region_erp command: find { find: "item_region_erp", filter: { ent_id: 1590271648210249400, region_code: "Q022", smg_out_key: { $exists: true }, status: "1", sale_price: { $gt: 0 }, $where: this.timestamp > this.smg_timestamp }, ntoreturn: 950, shardVersion: [ Timestamp 3000|4, ObjectId('5acbb4b0a7366023da49b822') ] } planSummary: IXSCAN { ent_id: 1, region_code: 1, item_code: 1, barcode: 1 } cursorid:112196383467 keysExamined:5859 docsExamined:5859 numYields:76 nreturned:950 reslen:902847 locks:{ Global: { acquireCount: { r: 158 } }, Database: { acquireCount: { r: 79 } }, Collection: { acquireCount: { r: 79 } } } protocol:op_command 1222ms




2018-08-01T22:00:31.367+0800 I COMMAND  [conn4986471] command omdmain.item_region_erp command: find { find: "item_region_erp", filter: { ent_id: 1590271648210249400, region_code: "Q022", smg_out_key: { $exists: true }, status: "1", sale_price: { $gt: 0 }, $where: this.timestamp > this.smg_timestamp }, ntoreturn: 950, shardVersion: [ Timestamp 3000|4, ObjectId('5acbb4b0a7366023da49b822') ] } planSummary: IXSCAN { ent_id: 1, region_code: 1, item_code: 1, barcode: 1 } cursorid:112196383467 keysExamined:5859 docsExamined:5859 numYields:76 nreturned:950 reslen:902847 locks:{ Global: { acquireCount: { r: 158 } }, Database: { acquireCount: { r: 79 } }, Collection: { acquireCount: { r: 79 } } } protocol:op_command 1222ms



%{WORD} %{MONGO_WORDDASH:database}\.%{MONGO_WORDDASH:collection} %{WORD}: %{MONGO_QUERY:query} %{WORD}:%{NONNEGINT:ntoreturn} %{WORD}:%{NONNEGINT:ntoskip} %{WORD}:%{NONNEGINT:nscanned}.*nreturned:%{NONNEGINT:nreturned}..+ (?<duration>[0-9]+)ms


%{TIMESTAMP_ISO8601:timestamp} %{MONGO3_SEVERITY:severity} %{MONGO3_COMPONENT:component}%{SPACE}(?:\[%{DATA:context}\])? %{GREEDYDATA:message}


{
"timestamp":"2018-08-01T22:24:44.497+0800",
"severity":"I",
"component":"COMMAND",
"context":"conn4987280",
"message":"command omdmain.item_region_erp command: find { find: "item_region_erp", filter: { ent_id: 1590271648210249400, region_code: "Q022", smg_out_key: { $exists: true }, status: "1", sale_price: { $gt: 0 }, $where: this.timestamp > this.smg_timestamp }, ntoreturn: 4850, shardVersion: [ Timestamp 3000|4, ObjectId('5acbb4b0a7366023da49b822') ] } planSummary: IXSCAN { ent_id: 1, region_code: 1, item_code: 1, barcode: 1 } cursorid:112999479763 keysExamined:59019 docsExamined:59019 numYields:541 nreturned:4850 reslen:4592724 locks:{ Global: { acquireCount: { r: 1084 } }, Database: { acquireCount: { r: 542 } }, Collection: { acquireCount: { r: 542 } } } protocol:op_command 6477ms"
}

'timestamp',"severity","component","context","message"

```

日志格式

datahub endpoint：
http://dh-cn-hangzhou.aliyun-inc.com
project:datahub_43_booboowei



[root@sh_02 td-agent]# cat td-agent.conf
<source>
  @type tail
  path /alidata/mongodb/log/test.log
  tag test
  format csv 
  keys id,name,gender,salary,my_time
</source>


<match test>
  @type datahub
  access_id LTAIbM8NZXpEV0DR
  access_key cDVWPPkjjUqtYY9bofnqfy8WNrfW7U
  endpoint http://dh-cn-hangzhou.aliyun-inc.com
  project_name datahub_43_booboowei
  topic_name mongodb_log_ana_43_booboowei
  column_names ["id", "name", "gender", "salary", "my_time"]
  flush_interval 1s
  buffer_chunk_limit 3m
  buffer_queue_limit 128
  dirty_data_continue true
  dirty_data_file /var/log/td-agent/dirty.file
  retry_times 3
  put_data_batch_size 1000
</match>

fluentd -c /alidata/install/fluentd/conf/datahub.conf


[root@sh_02 fluentd]# fluentd -c /alidata/install/fluentd/conf/datahub.conf
2018-08-08 17:21:21 +0800 [info]: parsing config file is succeeded path="/alidata/install/fluentd/conf/datahub.conf"
2018-08-08 17:21:26 +0800 [warn]: 'pos_file PATH' parameter is not set to a 'tail' source.
2018-08-08 17:21:26 +0800 [warn]: this parameter is highly recommended to save the position to resume tailing.
2018-08-08 17:21:26 +0800 [info]: using configuration file: <ROOT>
  <source>
    @type tail
    path "/alidata/mongodb/log/test.log"
    tag "test"
    format csv
    keys id,name,gender,salary,my_time
    <parse>
      keys id,name,gender,salary,my_time
      @type csv
    </parse>
  </source>
  <match test>
    @type datahub
    access_id "LTAIbM8NZXpEV0DR"
    access_key "cDVWPPkjjUqtYY9bofnqfy8WNrfW7U"
    endpoint "https://dh-cn-hangzhou.aliyuncs.com"
    project_name "datahub_43_booboowei"
    topic_name "mongodb_log_ana_43_booboowei"
    column_names ["id","name","gender","salary","my_time"]
    flush_interval 1s
    buffer_chunk_limit 3m
    buffer_queue_limit 128
    dirty_data_continue true
    dirty_data_file "/var/log/td-agent/dirty.file"
    retry_times 3
    put_data_batch_size 1000
    <buffer>
      flush_mode interval
      retry_type exponential_backoff
      flush_interval 1s
      chunk_limit_size 3m
      queue_limit_length 128
    </buffer>
  </match>
</ROOT>
2018-08-08 17:21:26 +0800 [info]: starting fluentd-1.2.4 pid=9655 ruby="2.3.7"
2018-08-08 17:21:26 +0800 [info]: spawn command to main:  cmdline=["/usr/local/bin/ruby", "-Eascii-8bit:ascii-8bit", "/usr/local/bin/fluentd", "-c", "/alidata/install/fluentd/conf/datahub.conf", "--under-supervisor"]
2018-08-08 17:21:31 +0800 [info]: gem 'fluent-plugin-datahub' version '0.12.25'
2018-08-08 17:21:31 +0800 [info]: gem 'fluent-plugin-grok-parser' version '2.1.6'
2018-08-08 17:21:31 +0800 [info]: gem 'fluentd' version '1.2.4'
2018-08-08 17:21:31 +0800 [info]: adding match pattern="test" type="datahub"
2018-08-08 17:21:31 +0800 [info]: adding source type="tail"
2018-08-08 17:21:31 +0800 [warn]: #0 'pos_file PATH' parameter is not set to a 'tail' source.
2018-08-08 17:21:31 +0800 [warn]: #0 this parameter is highly recommended to save the position to resume tailing.
2018-08-08 17:21:31 +0800 [info]: #0 starting fluentd worker pid=9665 ppid=9655 worker=0
2018-08-08 17:21:31 +0800 [info]: #0 following tail of /alidata/mongodb/log/test.log
2018-08-08 17:21:31 +0800 [info]: #0 fluentd worker is now running worker=0
2018-08-08 17:21:38 +0800 [info]: #0 Put data to datahub success, total 12



# 问题汇总

使用ruby2.6的时候出现bug，具体如下
https://bugs.ruby-lang.org/issues/14976

```shell
2018-08-08 16:31:35 +0800 [info]: starting fluentd-1.2.4 pid=24157 ruby="2.6.0"
2018-08-08 16:31:35 +0800 [info]: spawn command to main: cmdline=["/usr/local/bin/ruby", "-Eascii-8bit:ascii-8bit", "/usr/local/bin/fluentd", "-c", "/alidata/install/fluentd/conf/datahub.conf", "--under-supervisor"]
2018-08-08 16:31:35 +0800 [info]: gem 'fluent-plugin-datahub' version '0.12.25'
2018-08-08 16:31:35 +0800 [info]: gem 'fluent-plugin-grok-parser' version '2.1.6'
2018-08-08 16:31:35 +0800 [info]: gem 'fluent-plugin-mongo' version '1.1.2'
2018-08-08 16:31:35 +0800 [info]: gem 'fluent-plugin-tail-multiline' version '0.1.5'
2018-08-08 16:31:35 +0800 [info]: gem 'fluentd' version '1.2.4'
2018-08-08 16:31:35 +0800 [info]: adding match pattern="test" type="datahub"
2018-08-08 16:31:35 +0800 [info]: adding source type="tail"
2018-08-08 16:31:35 +0800 [warn]: #0 'pos_file PATH' parameter is not set to a 'tail' source.
2018-08-08 16:31:35 +0800 [warn]: #0 this parameter is highly recommended to save the position to resume tailing.
2018-08-08 16:31:35 +0800 [info]: #0 starting fluentd worker pid=24167 ppid=24157 worker=0
2018-08-08 16:31:35 +0800 [info]: #0 following tail of /alidata/mongodb/log/test.log
2018-08-08 16:31:35 +0800 [info]: #0 fluentd worker is now running worker=0
/usr/local/lib/ruby/gems/2.6.0/gems/fluentd-1.2.4/lib/fluent/event.rb:193: [BUG] Segmentation fault at 0x0000000000000000
ruby 2.6.0preview1 (2018-02-24 trunk 62554) [x86_64-linux]

-- Control frame information ---------------------------------------

```

解决方法：

将ruby改为2.3.6版本即可