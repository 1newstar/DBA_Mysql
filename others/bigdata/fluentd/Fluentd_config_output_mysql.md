# 输出至MySQL

> 2018-05-21 Booboo

[TOC]

## 1 安装软件

### Fluentd V0.12

> [Fluentd]?(https://www.fluentd.org/download)

```shell
$ gem install fluentd -v '~> 0.12.0'
```

### Ruby V2.6.0

> [Ruby]?(https://www.ruby-lang.org/zh_cn)

```shell
$ apt-get install openssl libssl-dev -y
$ wget https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.0-preview1.tar.gz
$ tar -xf ruby-2.6.0-preview1.tar.gz 
$ cd ruby-2.6.0-preview1
$ ./configure 
$ make
$ make install
$ ruby -v
$ gem -v
# 如果不显示最新版本则重启系统
# 如果之后添加的gem源是ssl的，需要编译以下内容
$ cd ext/openssl 
$ ruby extconf.rb --with-openssl-include=/usr/include/openssl/
```

### Gem repo

> [gem]?(https://ruby.taobao.org/)

```shell
$ gem source -l
$ gem source -r https://rubygems.org/
$ gem source -a https://gems.ruby-china.org/
```



### fluent-plugin-mysql v0.1.5

> 由于fluent-bit使用的v0.12版本，因此需要v0.1.5版本的插件，该信息可以在该git项目的readme中获取

```shell
$ apt-get install -y mariadb-server libmariadbclient-dev git 
$ git clone https://github.com/tagomoris/fluent-plugin-mysql.git
$ cd fluent-plugin-mysql && git checkout v0.1.5
$ gem install mysql2 jsonpath rake test-unit mysql2-cs-bind
$ gem build fluent-plugin-mysql.gemspec
$ gem install fluent-plugin-mysql-0.1.5.gem

```

## 2 配置文件

```shell
<source>
  @type http
  port 8888
  bind 0.0.0.0
</source>
<match mysql.input>
  @type mysql_bulk
  host localhost
  database booboo
  username root
  password uplooking
  column_names id,user_name,created_at,updated_at
  table mysqlapp
</match>
```

## 3 数据库新建表

```shell
create table booboo.mysqlapp (id int primary key auto_increment,user_name varchar(50),created_at datetime,update_at datetime);
```

## 4 测试记录

```shell
curl http://localhost:8888/mysql.input -d 'json={"user_name":"booboo","created_at":"2018-05-21 12:18:00","updated_at":"2018-05-21 12:19:00"}'

curl http://localhost:8888/mysql.input -d 'json={"user_name":"toyama","created_at":"2014/01/03 21:35:15","updated_at":"2014/01/03 21:35:15","dummy":"hogehoge"}'
```



## 详细步骤

```shell
# 安装ruby2.6忽略步骤
root@redis-01:/home/kiosk# ruby -v
ruby 2.6.0preview1 (2018-02-24 trunk 62554) [x86_64-linux]
root@redis-01:/home/kiosk# gem -v
2.7.6

# 修改gem源
root@redis-01:~$ gem source -l
*** CURRENT SOURCES ***

https://rubygems.org/
root@redis-01:~$ gem source -r https://rubygems.org/
https://rubygems.org/ removed from sources
root@redis-01:~$ gem source -a https://gems.ruby-china.org/
https://gems.ruby-china.org/ added to sources
rootk@redis-01:~$ gem source -l
*** CURRENT SOURCES ***

https://gems.ruby-china.org/


# 安装fluentd
root@redis-01:/alidata# gem install fluentd -v '~> 0.12.0'
Successfully installed fluentd-0.12.43
Parsing documentation for fluentd-0.12.43
Done installing documentation for fluentd after 1 seconds
1 gem installed


# 安装fluent-plugin-mysql插件
# 由于fluent-bit使用的v0.12版本，因此需要v0.1.5版本的插件
root@redis-01:/alidata# git clone https://github.com/tagomoris/fluent-plugin-mysql.git
Cloning into 'fluent-plugin-mysql'...
remote: Counting objects: 621, done.
remote: Total 621 (delta 0), reused 0 (delta 0), pack-reused 621
Receiving objects: 100% (621/621), 93.33 KiB | 0 bytes/s, done.
Resolving deltas: 100% (248/248), done.
Checking connectivity... done.
root@redis-01:/alidata# ll
total 24
drwxr-xr-x  6 root root 4096 May 21 13:54 ./
drwxr-xr-x 23 root root 4096 May  7 11:33 ../
drwxr-xr-x  4 root root 4096 May  7 11:37 consul/
drwxr-xr-x  5 root root 4096 May 21 13:54 fluent-plugin-mysql/
drwxr-xr-x  4 root root 4096 May 21 13:26 install/
drwxr-xr-x 10 root root 4096 May  7 11:34 redis/
root@redis-01:/alidata# cd fluent-plugin-mysql/
root@redis-01:/alidata/fluent-plugin-mysql# ll
total 60
drwxr-xr-x 5 root root  4096 May 21 13:54 ./
drwxr-xr-x 6 root root  4096 May 21 13:54 ../
-rw-r--r-- 1 root root  1071 May 21 13:54 fluent-plugin-mysql.gemspec
-rw-r--r-- 1 root root   104 May 21 13:54 Gemfile
drwxr-xr-x 8 root root  4096 May 21 13:54 .git/
-rw-r--r-- 1 root root   164 May 21 13:54 .gitignore
drwxr-xr-x 3 root root  4096 May 21 13:54 lib/
-rw-r--r-- 1 root root   589 May 21 13:54 LICENSE.txt
-rw-r--r-- 1 root root   227 May 21 13:54 Rakefile
-rw-r--r-- 1 root root 10976 May 21 13:54 README.md
-rw-r--r-- 1 root root  3697 May 21 13:54 README_mysql.md
drwxr-xr-x 3 root root  4096 May 21 13:54 test/
-rw-r--r-- 1 root root   144 May 21 13:54 .travis.yml


root@redis-01:/alidata/fluent-plugin-mysql# git tag
v0.0.1
v0.0.2
v0.0.3
v0.0.4
v0.0.5
v0.0.6
v0.0.7
v0.0.8
v0.0.9
v0.1.0
v0.1.1
v0.1.2
v0.1.3
v0.1.4
v0.1.5
v0.2.0
v0.2.1
v0.3.0
v0.3.1
v0.3.2

root@redis-01:/alidata/fluent-plugin-mysql# git show v0.1.5
tag v0.1.5
Tagger: toyama0919 <toyama0919@gmail.com>
Date:   Wed Oct 19 15:12:50 2016 +0900

Version 0.1.5

commit a12a354a3315d89dc8163f284a417b9d7aacdfcd
Merge: 269a9c6 08831d3
Author: Toyama Hiroshi <toyama0919@gmail.com>
Date:   Wed Oct 19 14:54:57 2016 +0900

    Merge pull request #37 from toyama0919/feature/fluentd-v0.12.X-only-support-latest-version
    
    Feature/fluentd v0.12.x only support latest version

root@redis-01:/alidata/fluent-plugin-mysql# git checkout v0.1.5
Note: checking out 'v0.1.5'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name

HEAD is now at a12a354... Merge pull request #37 from toyama0919/feature/fluentd-v0.12.X-only-support-latest-version


root@redis-01:/alidata/fluent-plugin-mysql# gem install mysql2 jsonpath rake test-unit mysql2-cs-bind

root@redis-01:/alidata/fluent-plugin-mysql# gem build fluent-plugin-mysql.gemspec
WARNING:  open-ended dependency on mysql2-cs-bind (>= 0) is not recommended
  if mysql2-cs-bind is semantically versioned, use:
    add_runtime_dependency 'mysql2-cs-bind', '~> 0'
WARNING:  open-ended dependency on jsonpath (>= 0) is not recommended
  if jsonpath is semantically versioned, use:
    add_runtime_dependency 'jsonpath', '~> 0'
WARNING:  open-ended dependency on rake (>= 0, development) is not recommended
  if rake is semantically versioned, use:
    add_development_dependency 'rake', '~> 0'
WARNING:  open-ended dependency on test-unit (>= 0, development) is not recommended
  if test-unit is semantically versioned, use:
    add_development_dependency 'test-unit', '~> 0'
WARNING:  See http://guides.rubygems.org/specification-reference/ for help
  Successfully built RubyGem
  Name: fluent-plugin-mysql
  Version: 0.1.5
  File: fluent-plugin-mysql-0.1.5.gem

  
root@redis-01:/alidata/fluent-plugin-mysql# gem install fluent-plugin-mysql-0.1.5.gem 
Fetching: msgpack-1.2.4.gem (100%)
Building native extensions. This could take a while...
Successfully installed msgpack-1.2.4
Fetching: yajl-ruby-1.4.0.gem (100%)
Building native extensions. This could take a while...
Successfully installed yajl-ruby-1.4.0
Fetching: cool.io-1.5.3.gem (100%)
Building native extensions. This could take a while...
Successfully installed cool.io-1.5.3
Fetching: http_parser.rb-0.6.0.gem (100%)
Building native extensions. This could take a while...
Successfully installed http_parser.rb-0.6.0
Fetching: sigdump-0.2.4.gem (100%)
Successfully installed sigdump-0.2.4
Fetching: thread_safe-0.3.6.gem (100%)
Successfully installed thread_safe-0.3.6
Fetching: tzinfo-1.2.5.gem (100%)
Successfully installed tzinfo-1.2.5
Fetching: tzinfo-data-1.2018.5.gem (100%)
Successfully installed tzinfo-data-1.2018.5
Fetching: string-scrub-0.0.5.gem (100%)
Building native extensions. This could take a while...
Successfully installed string-scrub-0.0.5
Fetching: fluentd-0.12.43.gem (100%)
Successfully installed fluentd-0.12.43
Successfully installed fluent-plugin-mysql-0.1.5
Parsing documentation for msgpack-1.2.4
Installing ri documentation for msgpack-1.2.4
Parsing documentation for yajl-ruby-1.4.0
Installing ri documentation for yajl-ruby-1.4.0
Parsing documentation for cool.io-1.5.3
Installing ri documentation for cool.io-1.5.3
Parsing documentation for http_parser.rb-0.6.0
Installing ri documentation for http_parser.rb-0.6.0
Parsing documentation for sigdump-0.2.4
Installing ri documentation for sigdump-0.2.4
Parsing documentation for thread_safe-0.3.6
Installing ri documentation for thread_safe-0.3.6
Parsing documentation for tzinfo-1.2.5
Installing ri documentation for tzinfo-1.2.5
Parsing documentation for tzinfo-data-1.2018.5
Installing ri documentation for tzinfo-data-1.2018.5
Parsing documentation for string-scrub-0.0.5
Installing ri documentation for string-scrub-0.0.5
Parsing documentation for fluentd-0.12.43
Installing ri documentation for fluentd-0.12.43
Parsing documentation for fluent-plugin-mysql-0.1.5
Installing ri documentation for fluent-plugin-mysql-0.1.5
Done installing documentation for msgpack, yajl-ruby, cool.io, http_parser.rb, sigdump, thread_safe, tzinfo, tzinfo-data, string-scrub, fluentd, fluent-plugin-mysql after 5 seconds
11 gems installed



```

