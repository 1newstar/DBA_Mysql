# -*- coding: utf-8 -*-
import MySQLdb
from prettytable import from_db_cursor #以表格的方式打印mysql执行结果

__author__ = 'Booboo Wei'
__write_time__ = '2017-08-01'

# 定义MySQLdb连接和操作的类
class mysqlhelper():
    def __init__(self,url,port,username,password,dbname,charset="utf8"):
        self.url=url
        self.port=port
        self.username=username
        self.password=password
        self.dbname=dbname
        self.charset=charset
        try:
            self.conn=MySQLdb.connect(self.url,self.username,self.password,self.dbname,self.port)
            self.conn.set_character_set(self.charset)
            self.cur=self.conn.cursor()
        except MySQLdb.Error as e:
            print("Mysql Error %d: %s" % (e.args[0], e.args[1]))


    def print_table(self,sql):
        """
        类似在mysql终端执行命令的结果输出，以表格形式
        :return str
        """
        self.cur.execute(sql)
        pt = from_db_cursor(self.cur)
        return pt

    def col_query(self, sql):
        '''
        打印表的列名
        :return list
        '''
        self.cur.execute(sql)
        index = self.cur.description
        result = []
        for res in self.cur.fetchall():
            row = {}
            for i in range(len(index)):
                row[index[i][0]] = res[i]
            result.append(row)
        return result

    def query(self,sql):
        try:
            n=self.cur.execute(sql)
            return n
        except MySQLdb.Error as e:
            print("Mysql Error:%s\nSQL:%s" %(e,sql))

    def queryRow(self,sql):
        """
        :param sql:string
        :return: result:tuple
        """
        self.query(sql)
        result = self.cur.fetchone()
        return result

    def queryAll_tuple(self,sql):
        """
        :param sql:string
        :return: result:tuple
        """
        self.query(sql)
        result = self.cur.fetchall()
        return result
  


    def queryAll_dict(self,sql):
        """
        :param sql:string
        :return: result:dict
        """
        self.query(sql)
        result=self.cur.fetchall()
        return dict(result)

    def print_one_column_list_string(self,result):
        """
        ['a','b']
        :param result:
        :return:"a","b"
        """
        a_list = []
        for i in result:
            a_list.append('"'+i+'"')
        a_str = ','.join(a_list)
        return a_str

    def print_one_column_liststring(self,result):
        """
        (('id',), ('order_id',))

        :param result:
        :return:
        """
        a_list = []
        for i in result:
            a_list.append(i[0])
        a = '''","'''.join(a_list)
        self.a_str = '["' + a + '"]'
        return self.a_str

    def print_one_column_list(self,result):
        a_list = []
        for i in result:
            a_list.append(i[0])
        return a_list


    def human(self,bytes):
        bytes = float(bytes)
        if bytes >= 1099511627776:
            terabytes = bytes / 1099511627776
            size = '%.0fT' % terabytes
        elif bytes >= 1073741824:
            gigabytes = bytes / 1073741824
            size = '%.0fG' % gigabytes
        elif bytes >= 1048576:
            megabytes = bytes / 1048576
            size = '%.0fM' % megabytes
        elif bytes >= 1024:
            kilobytes = bytes / 1024
            size = '%.0fK' % kilobytes
        else:
            size = '%.0fb' % bytes
        return size

    def commit(self):
        self.conn.commit()
  
    def close(self):
        self.cur.close()
        self.conn.close()

if __name__ == '__main__':
    print 'this is a mudule for mysqlcon named mysqlhelper()'
    url, port, username, password, dbname = ("ip", 3306, 'python', 'xxx', 'dba')
    mysql = mysqlhelper(url, port, username, password, dbname)
    dba_user = raw_input('请输入姓名[yt\hjx\wyp]: ')
    sql0 = """show tables;"""
    table_tuple = mysql.queryRow(sql0)
    if table_tuple is None or 'technical_archiving' not in table_tuple:
        sql1 = """create table technical_archiving(
    id int primary key auto_increment,
    company varchar(50) not null comment '客户名称',
    company_type varchar(50) not null comment '客户类型',
    event_start_time datetime not null comment '事件发起时间',
    case_database_type varchar(50) not null comment '数据库类型',
    case_database_carrier varchar(50) not null comment '数据库载体',
    case_event_type varchar(50) not null comment '事件类别',
    case_event_info varchar(50) not null comment '事件简述',
    dba varchar(50) not null comment 'DBA')
    comment '事件归档表';"""
        mysql.query(sql1)

    # 覆盖该用户的所有事件记录
    sql2 = """
    delete from technical_archiving where dba = '{}'
    """.format(dba_user)
    mysql.query(sql2)