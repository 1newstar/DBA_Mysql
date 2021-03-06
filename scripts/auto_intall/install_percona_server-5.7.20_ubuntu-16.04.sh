#!/bin/bash
# ubuntu

DIR=`pwd`
DATE=`date +%Y%m%d%H%M%S`

\mv /data/mysql /data/mysql.bak.$DATE &> /dev/null
mkdir -p /data/mysql
mkdir -p /data/mysql/data
mkdir -p /data/mysql/log
mkdir -p /data/install
mkdir -p /usr/local/mysql/bin
mkdir -p /data/mysql/mybinlog

cd /data/install
if [ `uname -m` == "x86_64" ];then
  if [ ! -f Percona-Server-5.7.20-18-Linux.x86_64.ssl100.tar.gz ];then
	 curl -O "https://www.percona.com/downloads/Percona-Server-LATEST/Percona-Server-5.7.20-18/binary/tarball/Percona-Server-5.7.20-18-Linux.x86_64.ssl100.tar.gz"
  fi
  tar -xzvf Percona-Server-5.7.20-18-Linux.x86_64.ssl100.tar.gz
  mv Percona-Server-5.7.20-18-Linux.x86_64.ssl100/* /data/mysql

fi

#install mysql
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql

\cp -f /data/mysql/support-files/mysql.server /etc/init.d/mysqld
sed -i 's#^basedir=$#basedir=/data/mysql#' /etc/init.d/mysqld
sed -i 's#^datadir=$#datadir=/data/mysql/data#' /etc/init.d/mysqld
cat > /etc/my.cnf <<END
[client]
port	= 3306
socket	= /tmp/mysql.sock

[mysql]
prompt="\u@AM_MySQL-01 \R:\m:\s [\d]> "
no-auto-rehash

[mysqld]
#skip-grant-tables
user	= mysql
port	= 3306
basedir	= /alidata/mysql
datadir	= /alidata/mysql/data
socket	= /tmp/mysql.sock
character-set-server = utf8mb4
skip_name_resolve = 1
slow_query_log = 1
slow_query_log_file = /alidata/mysql/dataslow.log
log-error = /alidata/mysql/dataerror.log
long_query_time = 0.1
log_queries_not_using_indexes =1
log_throttle_queries_not_using_indexes = 60
server-id = 2 # 建议改成ip地址的主机位
log-bin = /alidata/mysql/mybinlog
binlog_format = row
sync_binlog = 1
expire_logs_days = 30
master_info_repository = TABLE
relay_log_info_repository = TABLE
gtid_mode = on
enforce_gtid_consistency = 1
log_slave_updates
replicate_wild_ignore_table=mysql.%
replicate_wild_ignore_table=sys.%
replicate_wild_ignore_table=information_schema.%

[mysqldump]
quick
max_allowed_packet = 32M
END


chown -R mysql:mysql /data/mysql/
chown -R mysql:mysql /data/mysql/data/
chown -R mysql:mysql /data/mysql/log
/data/mysql/bin/mysqld --initialize-insecure --datadir=/data/mysql/data/  --user=mysql
ln -s /data/mysql/bin/mysqld /usr/local/mysql/bin/mysqld
chmod 755 /etc/init.d/mysqld
/etc/init.d/mysqld start

#add PATH
if ! cat /etc/profile | grep "export PATH=\$PATH:/data/mysql/bin" &> /dev/null;then
	echo "export PATH=\$PATH:/data/mysql/bin" >> /etc/profile
fi
source /etc/profile
cd $DIR
bash
