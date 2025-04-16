阅读《FreeSWITCH 权威指南》笔记。

外呼流程

1. 外呼先通过 fs 配置，进入 dialplan/public.xml 中 To_VOIP 扩展（省略部分命令）
    1.1 先 curl :4011/apps/appid_by_number 获取的结果 appid 设置为变量 lin_app_id
    1.2 再 curl :4011/apps/stream_tts 获取结果设置在 stream_tts 中（返回 0）
    1.3 再执行 lua 脚本，查看并发量设置 inlimit
    1.4 answer 接听
    1.5 转到 transfer in_ivr_park XML udesk_cti
2. 到达 udesk_cti context 中的 in_ivr_park 扩展，最终执行 park（挂起）
