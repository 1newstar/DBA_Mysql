# MySQL 强制修改参数

1. 修改配置文件
2. mysql> system gdb -p $(pidof mysqld) -ex "set opt_log_slave_updates=0" -batch
