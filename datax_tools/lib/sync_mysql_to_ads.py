# -*- coding:utf-8 -*-


import os,sys,time,re
from mysqlcon import mysqlhelper
from string import Template
reload(sys)
sys.setdefaultencoding('utf8')




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
        self.table_one_str = self.table_tuple[0][0]



    def get_reader_column(self,table):
        sql = """select column_name from information_schema.columns where table_name='{}';
        """.format(table)
        reader_column_tuple = self.mysql.queryAll_tuple(sql)
        reader_column = self.mysql.print_one_column_liststring(reader_column_tuple)
        return reader_column

    def get_reader_table(self,tables):
        """
        适用于多表同步到单表时，获取多表表名
        :input: table_list
        :return:
        "a"
        "a","b"
        """
        if len(tables) == 1:
            reader_table = '"'+tables[0]+'"'
        elif len(tables) > 1:
            reader_table = self.mysql.print_one_column_list_string(tables)
        else:
            exit(1)
        return reader_table



    def make_single(self,reader_datasource,partition):
        """
        单表到单表同步
        :param reader_datasource:
        :return:
        """
        reader_table_list = self.mysql.print_one_column_list(self.table_tuple)
        for table in reader_table_list:
            table_list = []
            table_list.append(table)
            reader_table = self.get_reader_table(table_list)
            reader_connectionTable = reader_table
            reader_column = self.get_reader_column(table)
            writer_table = reader_table
            writer_column = reader_column
            partition = partition
            a = open('../mould/mould_mysql_to_ads').read()
            s1 = Template(a)
            s2 = s1.substitute(reader_datasource = reader_datasource,reader_column = reader_column,reader_table = reader_table,reader_connectionTable = reader_connectionTable,writer_column = writer_column,writer_table = writer_table,partition=partition)
            yield s2


def main_one_to_one(url, port, username, password, dbname,reader_datasource,partition):
    sql = """
            select table_name
            from information_schema.tables
            where table_schema = "{}"
            """.format(dbname)
    mc = Mc_insert(url, port, username, password, dbname, sql)
    return mc.make_single(reader_datasource,partition)

if __name__ == "__main__":
    url, port, username, password, dbname = ("ip", 3306, 'root', 'xxx', 'vingoo_mc')
    reader_datasource = "manage"
    partition = "id"
    count = 1
    # 单对单
    for i in main_one_to_one(url, port, username, password, dbname,reader_datasource,partition):
        with open('../outfile/'+ str(count),'w') as outfile:
            outfile.write(i)
        count = count + 1

