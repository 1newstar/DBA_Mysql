# -*- coding:utf-8 -*-


import os,sys,time,re
from mysqlcon import mysqlhelper
from string import Template
reload(sys)
sys.setdefaultencoding('utf8')

"""
适用于自建dataX mysql to mysql replace
指定数据库中所有的表的一一映射同步 单对单

reader_username = 'root'
reader_password = 'password'
reader_datasource = 'jdbc:mysql://url:3306/dbname'
reader_table = 't1'

writer_username = 'root' 
writer_password =  'password'
write_dataresource = 'jdbc:mysql//url:3306/dbname' 
write_table = 't1'
"""



class Mc_insert():
    def __init__(self,url, port, username, password, dbname,sql):
        """
        :param url:
        :param port:
        :param username:
        :param password:
        :param dbname:
        :param sql:
        连接数据库并执行查表，返回tuple
        """
        self.mysql = mysqlhelper(url, port, username, password, dbname)
        self.table_tuple = self.mysql.queryAll_tuple(sql)


    def make_single(self,reader_username,reader_password,reader_datasource,writer_username,writer_password,write_dataresource):
        """
        单表到单表同步
        :param
        :return:
        """
        reader_table_list = self.mysql.print_one_column_list(self.table_tuple)
        for table in reader_table_list:
            a = open('../module/mould_mysql_to_mysql').read()
            s1 = Template(a)
            s2 = s1.substitute(reader_username = reader_username,reader_password = reader_password,reader_datasource = reader_datasource,reader_table = table,writer_username = writer_username,writer_password = writer_password,writer_dataresource = write_dataresource,writer_table = table)
            with open('../outfile/' + table + '.json', 'w') as outfile:
                outfile.write(s2)


if __name__ == "__main__":
    url, port, username, password, dbname = ("ip", 3306, 'root', 'xxx', 'vingoo_mc')
    reader_username = 'root'
    reader_password = 'password'
    reader_datasource = 'jdbc:mysql://url:3306/dbname'


    writer_username = 'root'
    writer_password =  'password'
    writer_dataresource = 'jdbc:mysql//url:3306/dbname'

    sql = """
            select table_name
            from information_schema.tables
            where table_schema = "{}"
            """.format(dbname)

    mc = Mc_insert(url, port, username, password, dbname, sql)
    mc.make_single(reader_username, reader_password, reader_datasource, writer_username, writer_password,
                   writer_dataresource)



