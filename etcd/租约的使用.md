# 租约的使用

租约（lease）是


```sh
etcdctl lease grant 120 # 授权一个租约 TTL 为 120s
# lease 084e8387f7aa7240 granted with TTL(120s)
etcdctl lease list      # 查看租约列表
etcdctl put name alice --lease="084e8387f7aa7240" # 为租约绑定一个 key/value
# OK                                            --成功返回此信息
# Error: etcdserver: requested lease not found  --失败返回此错误信息
etcdctl lease timetolive 084e8387f7aa7240 --keys  # 查看租约绑定的所有 keys
# lease 084e8387f7aa7240 granted with TTL(120s), remaining(54s), attached keys([name])  --成功信息
# lease 084e8387f7aa75b8 already expired                                                --如果不存在或已回收或已过期返回此信息
etcdctl lease keep-alive 084e8387f7aa7240 # 持久续约一个租约。连接不会断开，会在 **过期前** 一直发送心跳保持租约
etcdctl lease revoke 084e8387f7aa7240     # 回收一个租约，会自动删除与租约关联的所有 key，并自动停止 keep-alive
```
