# 02_TiDB测试安装

[TOC]

## 部署方式选择

[TiDB Ansible 部署方案](https://pingcap.com/docs-cn/op-guide/ansible-deployment/)

测试环境选择官方推荐的[TiDB-Ansible](https://github.com/pingcap/tidb-ansible) 进行安装。

## 准备机器

准备4台服务器，角色如下：

### Linux 操作系统版本

| Linux 操作系统平台       | 版本 |
| ------------------------ | ---- |
| Red Hat Enterprise Linux | 7.2  |

- TiDB 在 CentOS 7.3 的环境下进行过大量的测试，同时社区也有很多该操作系统部署的最佳实践，因此，建议使用 CentOS 7.3 以上的 Linux 操作系统来部署 TiDB。

### 开发及测试环境

| **组件** | **CPU** | **内存** | **本地存储** | **网络** | **实例数量(最低要求)** |
| -------- | ------- | -------- | ------------ | -------- | ---------------------- |
| TiDB     | 8核+    | 16 GB+   | SAS, 200 GB+ | 千兆网卡 | 1（与 PD 同机器）      |
| PD       | 4核+    | 8 GB+    | SAS, 200 GB+ | 千兆网卡 | 1（与 TiDB 同机器）    |
| TiKV     | 8核+    | 32 GB+   | SSD, 200 GB+ | 千兆网卡 | 3                      |

### 网络要求

TiDB 作为开源分布式 NewSQL 数据库，其正常运行需要网络环境提供如下的网络端口配置要求，管理员可根据实际环境中 TiDB 组件部署的方案，在网络侧和主机侧开放相关端口：

| 组件              | 默认端口 | 说明                                                         |
| ----------------- | -------- | ------------------------------------------------------------ |
| TiDB              | 4000     | 应用及 DBA 工具访问通信端口                                  |
| TiDB              | 10080    | TiDB 状态信息上报通信端口                                    |
| TiKV              | 20160    | TiKV 通信端口                                                |
| PD                | 2379     | 提供 TiDB 和 PD 通信端口                                     |
| PD                | 2380     | PD 集群节点间通信端口                                        |
| Pump              | 8250     | Pump 通信端口                                                |
| Drainer           | 8249     | Drainer 通信端口                                             |
| Prometheus        | 9090     | Prometheus 服务通信端口                                      |
| Pushgateway       | 9091     | TiDB，TiKV，PD 监控聚合和上报端口                            |
| Node_exporter     | 9100     | TiDB 集群每个节点的系统信息上报通信端口                      |
| Blackbox_exporter | 9115     | Blackbox_exporter 通信端口，用于 TiDB 集群端口监控           |
| Grafana           | 3000     | Web 监控服务对外服务和客户端(浏览器)访问端口                 |
| Grafana           | 8686     | grafana_collector 通信端口，用于将 Dashboard 导出为 PDF 格式 |
| Kafka_exporter    | 9308     | Kafka_exporter 通信端口，用于监控 binlog kafka 集群          |

### 客户端 Web 浏览器要求

TiDB 提供了基于 Prometheus 和 Grafana 技术平台作为 TiDB 分布式数据库集群的可视化监控数据展现方案。建议用户采用高版本的微软 IE，Google Chrome，Mozilla Firefox 访问 Grafana 监控入口。

