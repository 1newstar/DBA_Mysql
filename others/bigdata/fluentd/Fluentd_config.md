

# Fluentd ����

> 2018-05-18 BoobooWei

[TOC]

>  �����ļ������û�����`Fluentd`������������Ϊ��ͨ����1��ѡ���������������2��ָ������Ĳ�����`Fluentd`��������������������ļ��Ǳ���ġ� 

# �ο�����

[GitHub]?<https://github.com/fluent/fluentd> 

[Doc]?<http://docs.fluentd.org/articles/config-file> 

[Example]?<https://github.com/fluent/fluentd/tree/master/example> 

# �ļ�·��

## RPM or Deb

����㰲װ`Fluentd`���õ���`rpm`����`deb` �İ�װ������������ļ���`/etc/td-agent/td-agent.conf `���Ŀ¼�����°�װ���ᰲװ`conf` �����ļ��� 

Ĭ�������ļ�·����`/etc/td-agent-td-agent.conf`

## Gem

����㰲װ`Fluentd `�õ���`Ruby Gem`������Դ���һ�������ļ�����������������һ����ֹ�źŽ������°�װ�����ļ�����������޸��������ļ���`fluent.conf `�ļ���`ctrl c ` ��ֹ���̣�Ȼ���������ļ������������� 

```shell
$ ctrl c 

$fluentd -c fluent.conf

$ sudo fluentd --setup /etc/fluent
$ sudo vi /etc/fluent/fluent.conf
```

# ָ���б�

��������ļ�������ָ����ɣ� 

1. **source** Դָ�����������Դ��
2. **match**  ƥ��ָ��������Ŀ�ĵء�
3. **filter** ����ָ������¼�����ܵ���
4. **system** ϵͳָ������ȫ��ϵͳ���á�
5. **label** ��ǩָ������ڲ�·�ɵ�����͹��������顣
6. **@include**  @ָ���������һЩ�ļ���

## ����ָ�� Source Directive

`Fluentd` ������Դ��ͨ��ѡ�����������Ҫ��������ʹ��`source`ָ�`Fluentd`�ı�׼����������`http`��`forward`��ת����ģʽ�� 

ÿ��sourceָ��������һ��type�����ͣ�������type����ָ��������ʹ�á� 

- `http`��ʹ fluentd ת��Ϊһ�� httpd �˵㣬�Խ��ܽ���� http ���ġ�
- `forward`��ʹ fluentd ת��Ϊһ�� TCP �˵㣬�Խ��� TCP ���ġ�

### ������forward

#### �����ļ�˵�� 

```shell
# ���������ڼ���tcp/24224�ĳ�����־
# ������־ת����fluent-cat����
<source>
  @type forward
  port 24224
</source>
```

#### ��ϰ1_ʵ��python������־�Ѽ�����׼�����Ĭ����־�ļ�

> Ŀ�꣺
>
> * ѧϰʹ��������forward
> * Source��ͨ��python���������־�Ѽ�
> * Match����־��׼�����`/var/log/td-agent/td-agent.log`

��һ�� �޸������ļ�`vim /etc/td-agent/td-agent.conf`;��������

```shell
$ vim /etc/td-agent/td-agent.conf
<source>
  @type forward
  port 24224 #������tcp�˿�
</source>

<match fluentd.test.**> # match��������ݿ����ȿ�����һ��tag��ʶ���ţ�������python�����л�ʹ��
@type stdout # �˴�ʹ�ñ�׼����Ĳ�����Ὣ��־�����td-agent.log
</match>

$ /etc/init.d/td-agent restart
```

�ڶ����� ��дpython����

```shell
## python����Ҫ�ܹ�����fluentd������Ҫ��������python��fluent-logger
## �Ȱ�װpip����
$ apt-get install python-pip python-dev build-essential 
## ͨ��pip��װfluent-logger
$ pip install fluent-logger
## python��������
## --test.py
from fluent import sender
from fluent import event
# ����fluentd����ָ��tagΪ fluentd.test,fluentd�����ڱ���localhost���˿�Ϊ24224
sender.setup('fluentd.test', host='localhost', port=24224)
# ��Ҫת������־��Ϣ���¼�Ϊfollow���¼�����ϸ��Ϣ��һ���ֵ�{'from':'userA','to':'userB'}
event.Event('follow', {
  'from': 'userA',
  'to':   'userB'
})
```

������ ִ��python����

```shell
$ python test.py
```

���Ĳ� �鿴��־���

```shell
$ tail -f /var/log/td-agent/td-agent.log

2018-05-16 17:08:35 +0800 [info]: adding match pattern="fluentd.test.**" type="stdout"
2018-05-16 17:08:35 +0800 [info]: adding source type="forward"
2018-05-16 17:08:35 +0800 [info]: adding source type="http"
2018-05-16 17:08:35 +0800 [info]: adding source type="debug_agent"
2018-05-16 17:08:35 +0800 [info]: #0 starting fluentd worker pid=10505 ppid=10500 worker=0
2018-05-16 17:08:35 +0800 [info]: #0 [input_debug_agent] listening dRuby uri="druby://127.0.0.1:24230" object="Fluent::Engine"
2018-05-16 17:08:35 +0800 [info]: #0 listening port port=24224 bind="0.0.0.0"
2018-05-16 17:08:35 +0800 [info]: #0 fluentd worker is now running worker=0
2018-05-16 17:09:02.000000000 +0800 fluentd.test.follow: {"to":"userB","from":"userA"}

# match pattern="fluentd.test.**" type="stdout" �ĺ�����ƥ�䵽��ǩΪ'fluentd.test'��ͷ��ģʽ��Ϣ����Щ��־��Ϣ�ŵ���׼�����td-agent.log��
# 2018-05-16 17:09:02.000000000 +0800 fluentd.test.follow: {"to":"userB","from":"userA"} ������Ϣ�ĺ��������һ����־��Ϣ����־��tagΪfluentd.test �¼�Ϊfollow����ϸ��ϢΪjson��ʽ����Ϣ{"to":"userB","from":"userA"}
```

### ������http

#### �����ļ�˵��

```shell
# http://this.host:9880/myapp.access?json={"event":"data"} 
# myapp.access���Ǳ�ǩ.�¼�
<source>
  @type http
  port 9880
</source>
```

#### ��ϰ2_http���룬stdout���

> Ŀ�꣺
>
> - ѧϰʹ��������http
> - Source��ͨ��http���������־�Ѽ�
> - Match����־��׼�����`/var/log/td-agent/td-agent.log`

��һ�� �޸������ļ�����������

```shell
# �Ѽ�8888�˿ڵ�http������־
<source>
    @type http
    port 8888  #fluentd����ͨ��8888�˿����Ѽ�http����Ϣ
    bind 0.0.0.0
</source>
# ���ƥ�䵽booboo��ǩ����־��Ϣ��td-agent.log
<match booboo.**>
    @type stdout
</match>

$ /etc/init.d/td-agent restart
```

�ڶ��� ����http����

* Linux��ͨ��curl��������

```shell
curl http://192.168.1.5:8888/booboo_file -d 'json={"booboo_file":"ָ���ļ�"}'
curl http://localhost:8888/booboo -d 'json={"name":"booboo"}'
```

* �����������`http://192.168.1.5:8888/booboo_file?json={"booboo_file":"ָ���ļ�"}`

![1526638293055](pic\02.png)



������ �鿴�Ѽ�����־��Ϣ

```shell
$ tail -n 1 /var/log/td-agent/td-agent.log 
2018-05-18 16:26:48.153516800 +0800 booboo: {"name":"booboo"}
```



#### ��ϰ3_http���룬ָ���ļ����

> Ŀ�꣺
>
> - ѧϰʹ��������http
> - Source��ͨ��http���������־�Ѽ�
> - Match����־��׼�����`/var/log/td-agent/td-agent.log`

��һ�� �޸������ļ�����������

```shell
# �Ѽ�8888�˿ڵ�http������־
<source>
    @type http
    port 8888  #fluentd����ͨ��8888�˿����Ѽ�http����Ϣ
    bind 0.0.0.0
</source>
# ���ƥ�䵽booboo_file��ǩ����־��Ϣ��ָ�����ļ�/var/log/td-agent/booboo_file�ļ�
<match booboo_file.**>
    @type file
    path /var/log/td-agent/booboo_file
</match>

$ /etc/init.d/td-agent restart
```

�ڶ��� ����http����

- Linux��ͨ��curl��������

```shell
curl http://192.168.1.5:8888/booboo_file -d 'json={"booboo_file":"ָ���ļ�"}'
```

- �����������`http://192.168.1.5:8888/booboo_file?json={"booboo_file":"ָ���ļ�"}`

![1526632617656](pic\03.png)



������ �鿴�Ѽ�����־��Ϣ

```shell
$ tail -n 1 /var/log/td-agent/booboo_file/buffer.b56c781ee19310426542cc19e3db769f1.log
2018-05-18T18:07:33+08:00	booboo_file	{"booboo_file":"ָ���ļ�"}
```

### Source Directive����С��

ÿ�� source ָ�������� ��type�� ������ָ��ʹ�����ֲ����

**Routing��·�ɣ�**��source ���¼��ύ�� fluentd ��·�������С�һ���¼�������ʵ����ɣ�tag��time �� record��

- `tag`����һ��ͨ�� ��.�� ��������ַ�����e.g. myapp.access�������� Fluentd �ڲ�·������ķ���
- `time`��ʱ���ֶ���������ָ�������ұ���Ϊ Unix ʱ���ʽ��
- `record`��һ�� JSON ����

��`��ϰ3_http���룬ָ���ļ����`��

**Plugin�������**

�û�������չ����ԴFluentd��ͨ����д�Լ��Ĳ��������Ĭ��ѡ�Ϊ�˽�һ������fluentd ����Ϣ����ο� [Input Plugin Overview](http://docs.fluentd.org/articles/input-plugin-overview) ���¡�

- [in_tail](https://docs.fluentd.org/v1.0/articles/in_tail)
- [in_forward](https://docs.fluentd.org/v1.0/articles/in_forward)
- [in_udp](https://docs.fluentd.org/v1.0/articles/in_udp)
- [in_tcp](https://docs.fluentd.org/v1.0/articles/in_tcp)
- [in_http](https://docs.fluentd.org/v1.0/articles/in_http)
- [in_syslog](https://docs.fluentd.org/v1.0/articles/in_syslog)
- [in_exec](https://docs.fluentd.org/v1.0/articles/in_exec)
- [in_dummy](https://docs.fluentd.org/v1.0/articles/in_dummy)
- [in_windows_eventlog](https://docs.fluentd.org/v1.0/articles/in_windows_eventlog)

## ���ָ�� Match Directive

`match` ָ�����ƥ�� ��tags�� ���¼������������ǡ�`match` ���������÷��ǽ��¼����������ϵͳ����ˣ��� `match` �����Ӧ�Ĳ����Ϊ ��������������?`Fluentd �ı�׼���������� file �� forward��` 

### match ƥ��ģʽ

| ƥ��ģʽ  | ˵��                                                         | ����                                                |
| --------- | ------------------------------------------------------------ | --------------------------------------------------- |
| `*`       | ƥ�䵥��` tag` ����                                          | `a.*`��ƥ�� `a.b`������ƥ�� `a` ���� `a.b.c`        |
| `**`      | ƥ�� `0 `�� `��� tag` ����                                  | `a.**`��ƥ�� `a`��`a.b` �� `a.b.c`                  |
| `{X,Y,Z}` | ƥ�� `X`��`Y` ��`Z`������` X`��`Y` �� `Z` ��ƥ��ģʽ�����Ժ� `* `�� `** `ģʽ���ʹ�� | `{a, b}`��ƥ��` a `��` b`������ƥ��` c`             |
| `<match>` | �����ģʽ����һ��`<match>`��ǩ����һ�������ո�ָ�����ʱ����ƥ���κ��г���ģʽ | `<match a.** b.*>`ƥ�� `a`��`a.b`��`a.b.c` �� `b.d` |

`Fluentd` ���԰��������������ļ��г��ֵ�˳�򣬴��ϵ��������� "`tags`" ƥ�� �� 


![Fluentd v1.0 Plugin API Overview](pic/04.png) 

* `stdout`����׼�����/var/log/td-agent/td-agent.log
* `file`:�����ָ���ļ�
* `forward`��ת����ָ����������tcp�����˿�



### ������stdout

#### �����ļ�˵��

```shell
<match fluentd.test.**> # match��������ݿ����ȿ�����һ��tag��ʶ����
@type stdout # �˴�ʹ�ñ�׼����Ĳ�����Ὣ��־�����td-agent.log
</match>
```

#### ��ϰ2_http���룬stdout���

��ϰͬ��

### ������file

#### �����ļ�˵��

```shell
<match booboo_file.**> #ƥ�䵽booboo_file��tag�������ָ��Ŀ¼��
    @type file
    path /var/log/td-agent/booboo_file
</match>
```

#### ��ϰ3_http���룬ָ���ļ����

��ϰͬ��

### ������forward 

> [��������]https://www.jianshu.com/p/c8a5cd7f7f70

`forward`�������������¼�ת��������`Fluentd`�ڵ㡣������֧��`����ƽ��`��`�Զ�����ת��`��Ack.Active Active���ݣ������ڸ��ƣ���ʹ��`copy`���Ʋ����

`forward`���ʹ�á���accrual failure detector ���㷨�����������ϡ������Զ����㷨�Ĳ����������������ϻָ�ʱ�����ʹ�������ڼ����Ӻ��Զ����á�

`forward`������֧��һ�κ�����һ�����塣Ĭ��ֵ���Ϊһ�Ρ�

#### �����ļ�˵��

```shell
<match pattern>
  @type forward
  send_timeout 60s #�����¼���־�ĳ�ʱʱ�䡣 Ĭ��ֵΪ60��
  recover_wait 10s #���ܷ��������ϻָ�֮ǰ�ĵȴ�ʱ�䡣 Ĭ��ֵΪ10�롣
  hard_timeout 60s #���ڼ����������ϵ�Ӳ��ʱ�� Ĭ��ֵ����send_timeout������

  <server> # ת����Ŀ�������������һ��server
    name myserver1
    host 192.168.1.3 #��������IP��ַ��������
    port 24224 #�����Ķ˿ں�
    weight 60 #����ƽ�������� ���һ����������Ȩ��Ϊ20����һ����������Ȩ��Ϊ30�����¼���2��3�ı��ʷ��͡� Ĭ��Ȩ��Ϊ60��
  </server>
  <server>
    name myserver2
    host 192.168.1.4
    port 24224
    weight 60
  </server>
  ...

  <secondary> # ��ѡ�����������������server�����ˣ���ô�ͷ��ڱ���ָ��Ŀ¼��
    @type file
    path /var/log/fluent/forward-failed
  </secondary>
</match>
```

#### ��ϰ4_�Fluentd�Զ�����ת�Ƽܹ�

> [HA]https://docs.fluentd.org/v1.0/articles/high-availability
>
> Ŀ�꣺ѧϰʹ��������forwardʵ���Զ�����ת��

![](pic/05.png)

��������

To configure Fluentd for high availability, we assume that your network consists of ��*log forwarders*�� and ��*log aggregators*��.

`Fluentd`�ĸ߿��������ã��ɡ���־�����͡���־���ϡ���ɡ����ص��Ѽ���־�ķ�����Ϊ`��־���������`��������̨�����ϵĳ�Ϊ`��־���Ϸ�����`

**��־�������������**

```shell
# TCP input
<source>
  @type forward
  port 24224
</source>

# HTTP input
<source>
  @type http
  port 8888
</source>

# Log Forwarding
<match mytag.**>
  @type forward

  # primary host
  <server>
    host 192.168.0.1
    port 24224
    weight 60
  </server>
  # use secondary host
  <server>
    host 192.168.0.2
    port 24224
    weight 40
    #standby #�����standby��Ϊ����ת�� ���û��strandby��Ϊ���ؾ���
  </server>
  
  <secondary>
    @type file
    path /var/log/fluent/forward-failed
  </secondary>
  
  # use longer flush_interval to reduce CPU usage.
  # note that this is a trade-off against latency.
  <buffer>
    flush_interval 60s
  </buffer>
</match>
```

**��־���Ϸ���������**

```shell
# Input
<source>
  @type forward
  port 24224
</source>

# Output  ��ƥ��ǳ���Ҫ������ƥ�������ռ��˵�<match mytag.**>��ƥ�䵽����Ϣ����׼���
<match mytag.**>  
  @type stdout
</match>
```

### Match Directive����С��

#### **Plugin�������**

> https://docs.fluentd.org/v1.0/articles/output-plugin-overview

�������Ļ�������Ϊ������еĻ����ɵ����Ļ�����������塣 ����Ϊÿ��������ѡ��ͬ�Ļ���������� һЩ����������ȫ�Զ���ģ���ʹ�û�������

##### Non-Buffered

�ǻ������������������ݲ�����д�������

* out_copy
* out_stdout
* out_null

##### Buffered

ʱ����Ƭ��������ʵ����һ�ֻ������������ǰ�ʱ�����ġ�

* out_exec_filter
* out_forward
* out_mongo or out_mongo_replset
* out_exec
* out_file
* out_s3
* out_webhdfs