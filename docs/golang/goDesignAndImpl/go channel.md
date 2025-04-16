# go channel

- 用 `for range CHANNLE` 的时候一定要注意关闭 CHANNEL，否则就要用其他机制来确保能退出，可以用 `for { select case1 CHANNEL, case2 TIMEOUT}` 来替代
