# 添加节点操作流程

## ETCD 添加节点执行操作的整体策略

1. 集群中三个 etcd 服务，先上线一个新的 etcd 服务（加入集群并启动成功），然后下线一个旧的，再次重复一次以使三个服务分布到三台机器上。
2. 两台新机器一个是从机器 sh-xcc1-etcd01 镜像来的，所以可以在两台新机器上 **分别** 用 /usr/local/etcd 下 etcd2、etcd3 目录

 --initial-cluster-state new --initial-cluster-token s2-etcd-cluster

## 预备命令检查信息

依次执行，记录并观察结果：

```sh
export ETCDCTL_API=3 # 设置变量
# 下面是 s5 集群 etcd
etcdctl --endpoints="http://10.90.88.28:2380,http://10.90.254.41:2380,http://10.90.91.36:2380" member list
etcdctl --endpoints="http://10.90.88.28:2380,http://10.90.254.41:2380,http://10.90.91.36:2380" endpoint status --write-out=table
etcdctl --endpoints="http://10.90.88.28:2380,http://10.90.254.41:2380,http://10.90.91.36:2380" endpoint health --write-out=table

# 下面是 s2 集群，01: 187, 02: 215, 03: 216
etcdctl --endpoints="http://10.11.54.187:2378,http://10.11.54.215:2378,http://10.11.54.216:2378" member list --write-out=table
etcdctl --endpoints="http://10.11.54.187:2378,http://10.11.54.215:2378,http://10.11.54.216:2378" endpoint status --write-out=table
etcdctl --endpoints="http://10.11.54.187:2378,http://10.11.54.215:2378,http://10.11.54.216:2378" endpoint health --write-out=table
```

获取信息：那个 etcd 是主节点（0921日是 infra1）、另外两个节点的 ID、 PEER_URL 信息
获取主机 IP 信息： ifconfig eth0


## 集群加节点

准备好 NEW_NAME 和 PEER_URL 执行：
etcdctl --endpoints="http://10.11.54.187:2389" member add {NEW_NAME} --peer-urls="http://{NEW_PEER_HOST:NEW_PORT}"

（可以收集返回的信息，填充到下方脚本中，尤其是 ETCD_INITIAL_CLUSTER 比较长）

---

查看节点列表、状态（注意 endpoints 的变化）：

```sh
export ETCDCTL_API=3 # 设置变量
etcdctl --endpoints="http://10.11.54.215:2389,http://10.11.54.216:2389,http://10.11.54.187:2389" member list
etcdctl --endpoints="http://10.11.54.215:2389,http://10.11.54.216:2389,http://10.11.54.187:2389" endpoint status --write-out=table
etcdctl --endpoints="http://10.11.54.215:2389,http://10.11.54.216:2389,http://10.11.54.187:2389" endpoint health --write-out=table
```

---

修改脚本 launch.sh

- 用获取到的 IP 信息替换 LOCAL 变量
- 更换 NAME 就是上条命令中的 NEW_NAME
- 将上条命令的结果 ETCD_INITIAL_CLUSTER 更换下方的 EPS_WITH_NAME
- 确认 \*\_DB\_PATH 的目录（etcdN 的变更)
- （有增删后需要进行的操作）将 EPS_WITH_NAME 更换为已运行节点的信息，注意格式保持
- 注：log 文件可以不变更
- 注：删除原数据文件 /usr/local/etcd/etcdN/ 下的 data 和 wal （sudo）

```sh
#!/bin/bash

LOCAL=10.11.54.187
NAME=infra2
CUR_PEER_URL=http://${LOCAL}:2368
CUR_CLI_URL=http://${LOCAL}:2379

EPS_WITH_NAME=infra0=http://10.11.54.187:2388,infra1=http://10.11.54.187:2378,infra2=http://10.11.54.187:2368

DATA_DB_PATH=/usr/local/etcd/etcd3/data
WAL_DB_PATH=/usr/local/etcd/etcd3/wal

etcd --name ${NAME} \
  --data-dir=${DATA_DB_PATH} \
  --wal-dir=${WAL_DB_PATH} \
  --auto-compaction-retention=1m \
  --snapshot-count=5000 \
  --quota-backend-bytes=$((6*1024*1024*1024)) \
  --initial-advertise-peer-urls ${CUR_PEER_URL} \
  --listen-peer-urls ${CUR_PEER_URL} \
  --listen-client-urls ${CUR_CLI_URL} \
  --advertise-client-urls ${CUR_CLI_URL} \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster ${EPS_WITH_NAME} \
  --initial-cluster-state existing > /var/log/etcd/etcd3.log 2>&1
```

---

执行脚本： sudo nohup ./launch.sh &

查看日志： /var/log/etcd/etcd.log

查看节点列表、状态（注意 endpoints 的变化）：
etcdctl --endpoints="http://10.11.54.187:2379,http://10.11.54.187:2389,http://10.11.54.187:2399" member list
etcdctl --endpoints="http://10.11.54.187:2379,http://10.11.54.187:2389,http://10.11.54.187:2399" endpoint status --write-out=table
etcdctl --endpoints="http://10.11.54.187:2379,http://10.11.54.187:2389,http://10.11.54.187:2399" endpoint health --write-out=table

查看状态期望正常

---

下线一个旧 etcd 服务：
执行命令： `etcdctl --endpoints="http://10.11.54.187:2389" member remove <OLD_ID>`

## 检查节点命令

```sh
#!/bin/bash
ep=`ps -ef | grep etcd | grep -Eo 'advertise-client-urls [^ ]*' | head -n 1 | grep -Eo 'http.*'`

if [[ $ep =~ ^http://[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9]{4,5}$ ]]; then
    echo -e "one endpoint is: $ep"
else
    echo "ERR: got endpoint $ep, you can get and set ep by manual"
    exit 1
fi

echo "cluster-health"
sudo docker run --rm registry.cn-hangzhou.aliyuncs.com/udesk-cicd/etcd:3.3.20-v2 /usr/local/bin/etcdctl --endpoints "$ep" cluster-health

memList=`sudo docker run --rm registry.cn-hangzhou.aliyuncs.com/udesk-cicd/etcd:3.3.20-v2 /usr/local/bin/etcdctl --endpoints "$ep" member list`
echo -e "\nmember list:"
echo -e "$memList\n"

lineCount=`echo "$memList" | wc -l`
if [ $lineCount -lt 2 ]; then
    echo "ERR: etcd member list less than 2, please check the endpoint"
    exit 1
fi

eps=`echo $memList | grep -Eo 'client[^ ]* ' | grep -Eo 'http:[^ ]*' | tr '\n' ','`
eps=${eps%,}
echo -e "endpoints are: $eps\n"

echo -e "endpoint status:"
sudo docker run -e ETCDCTL_API=3 --rm registry.cn-hangzhou.aliyuncs.com/udesk-cicd/etcd:3.3.20-v2 /usr/local/bin/etcdctl --endpoints "$eps" endpoint status --write-out=table

echo -e "\nendpoint health:"
sudo docker run -e ETCDCTL_API=3 --rm registry.cn-hangzhou.aliyuncs.com/udesk-cicd/etcd:3.3.20-v2 /usr/local/bin/etcdctl --endpoints "$eps" endpoint health --write-out=table
```

## 2024年9月12日

### D3 环境中

```sh
# docker 的 etcd-node-1=http://10.1.163.116:12380,
etcd-node-2=http://10.1.163.116:22380,etcd-node-4=http://10.1.17.83:2388,etcd-node-1=http://10.1.163.116:12380,etcd-node-5=http://10.1.17.83:2378

export ETCDCTL_API=3 # 设置变量
etcdctl --endpoints="http://10.1.163.116:32380,http://10.1.163.116:22380,http://10.1.17.83:2388,http://10.1.163.116:12380,http://10.1.17.83:2378" member list --write-out=table
etcdctl --endpoints="http://10.1.163.116:32380,http://10.1.163.116:22380,http://10.1.17.83:2388,http://10.1.163.116:12380,http://10.1.17.83:2378" endpoint status --write-out=table
etcdctl --endpoints="http://10.1.163.116:32380,http://10.1.163.116:22380,http://10.1.17.83:2388,http://10.1.163.116:12380,http://10.1.17.83:2378" endpoint health --write-out=table

etcd --name etcd-node-3 --data-dir=/usr/local/etcd/etcd3/data --wal-dir=/usr/local/etcd/etcd3/wal --auto-compaction-retention=1m --snapshot-count=5000 --quota-backend-bytes=6442450944 --initial-advertise-peer-urls http://10.1.163.116:32380 --listen-peer-urls http://10.1.163.116:32380 --listen-client-urls http://10.1.163.116:32379 --advertise-client-urls http://10.1.163.116:32379 --initial-cluster-token etcd-cluster-1 --initial-cluster etcd-node-3=http://10.1.163.116:32380,etcd-node-2=http://10.1.163.116:22380,etcd-node-4=http://10.1.17.83:2388,etcd-node-1=http://10.1.163.116:12380,etcd-node-5=http://10.1.17.83:2378 --initial-cluster-state existing
```

### S2 线上环境

```sh
# 01: 187, 02: 215, 03: 216
export ETCDCTL_API=3 # 设置变量
etcdctl --endpoints="http://10.11.54.187:2378,http://10.11.54.215:2378,http://10.11.54.216:2378" member list --write-out=table
etcdctl --endpoints="http://10.11.54.187:2378,http://10.11.54.215:2378,http://10.11.54.216:2378" endpoint status --write-out=table
etcdctl --endpoints="http://10.11.54.187:2378,http://10.11.54.215:2378,http://10.11.54.216:2378" endpoint health --write-out=table

# etcd03 上跑的命令
etcd --name infra-3 --data-dir=/usr/local/etcd/data --wal-dir=/usr/local/etcd/wal --auto-compaction-retention=1m --snapshot-count=5000 --quota-backend-bytes=6442450944 --initial-advertise-peer-urls http://10.11.54.216:2378 --listen-peer-urls http://10.11.54.216:2378 --listen-client-urls http://10.11.54.216:2389 --advertise-client-urls http://10.11.54.216:2389 --initial-cluster-token etcd-cluster-1 --initial-cluster infra0=http://10.11.54.187:2388,infra1=http://10.11.54.187:2378,infra2=http://10.11.54.187:2368,infra-2=http://10.11.54.215:2378,infra-3=http://10.11.54.216:2378 --initial-cluster-state existing

# 创建 etcd 01 命令
nohup etcd --name infra0 --data-dir=/usr/local/etcd/data --wal-dir=/usr/local/etcd/wal --auto-compaction-retention=1m --snapshot-count=5000 --quota-backend-bytes=6442450944 --initial-advertise-peer-urls http://10.11.54.187:2378 --listen-peer-urls http://10.11.54.187:2378 --listen-client-urls http://10.11.54.187:2389 --advertise-client-urls http://10.11.54.187:2389 --initial-cluster-token etcd-cluster-1 --initial-cluster infra0=http://10.11.54.187:2378,infra-2=http://10.11.54.215:2378,infra-3=http://10.11.54.216:2378 --initial-cluster-state existing  > /var/log/etcd/etcd.log 2>&1 &
# 执行 OK
```

### redis 操作

redis6

- 连接 sentinel 命令 `redis-cli -h 10.11.54.216 -p 27690 -a "ORjPtnqVDlrlnkP5KoT5"`
- `sentinel_addresses6 = ['10.11.54.215:27690', '10.11.54.216:27690', '10.11.54.187:27690']`
- 连接 server 命令 `redis-cli -h 10.11.54.216 -p 7790 -a "ORjPtnqVDlrlnkP5KoT5"`

```
```
