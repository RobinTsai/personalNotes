# pike module

[pike 模块](https://kamailio.org/docs/modules/5.4.x/modules/pike.html)追踪所有（或指定的）请求的来源 IP，判断是否超出限制（pike 模块不做任何拒绝操作）。

## 变量

- `sampling_time_unit` 采样周期（秒），越小越好但越慢，检测高峰要用小值。默认 2
- `reqs_density_per_unit`  在采样周期内的请求密度，以此为阈值，默认 30（但超限不是准确的这个数值，对于 IPv4 是在 x~3x 之间）。
- `remove_latency` 指定上次请求的 IP 在内存中的滞留时间（秒）

## 方法（就一个）

- `pike_check_req()` 判断当前请求 IP 是否未超限。

## RPC 命令

- `kamcmd pike.top [ALL|HOT|WARM]` 列出 pike 树中的节点

## RPC 调用

- `kamcli rpc pike.top ALL`

## 开发指导

- pike 模块用了一个字典树存储追踪的 IP，每个 node 是一个 Byte，从根到叶子指定一个 IP。
- 所以对于 IPv4 会有 4 个节点
- 第一个节点计数到 1 就算满；最后一个节点从 0 开始计数；中间的节点在前一个节点记满 x（`reqs_density_per_unit`）后创建并和前一个节点均分后某称 `x/2` 的数值
- 叶子节点满 x 次后，标记为 RED，即超限。
- 公式总结如下 `1 + x + (x/2)*(n-2) + (x-1)`（n 为 IP 中 Byte 数量）
- 因此 IPv4（4B）最小次数是 x 次，最大次数是 3x 次
- 因此 IPv6（16B）最小次数是 x 次，最大次数是 9x 次
