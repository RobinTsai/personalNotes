# docker

https://docs.docker.com/engine/install/ubuntu/
https://cn.linux-console.net/?p=4837

```sh
# ubuntu 18.04 安装 docker
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
apt install docker.io

vim /etc/docker/daemon.json # 配置 docker 镜像源
# {
#   "registry-mirrors": ["https://hub-mirror.c.163.com", "https://mirror.baidubce.com", "https://ccr.ccs.tencentyun.com", "https://dockerproxy.com"]
# }

systemctl restart docker.service # stop + start
docker pull ubuntu:18.04
```

## 制作一个 FreeSWITCH 镜像

```sh
docker pull ubuntu:18.04
```
