# gRPC 如何使用 Header

gRPC 收到 Header 默认都是小写的，如果不想转换，都设置成小写最好了

## 调用端传递 Header 到 gRPC

在调用端调用 gRPC 前添加代码写入 Header：

```go
// GrpcAddHeaderTrackID 向 ctx 中添加 "x-track-id" header，其会在调用的时候传到服务端
func GrpcAddHeaderTrackID(ctx context.Context, value string) context.Context {
	md := metadata.New(map[string]string{"x-track-id": value})
	return metadata.NewOutgoingContext(ctx, md)

    // 如果用这种方式，则允许多个相同的 header 存在
    // ctx = metadata.AppendToOutgoingContext(ctx, "x-track-id", value)
}
```

在服务端添加代码接收 Header：

```go
// GrpcGetHeaderTrackID 从 ctx 中读取 header，并返回 x-track-id Header 的值
func GrpcGetHeaderTrackID(ctx context.Context) string {
	if md, _ := metadata.FromIncomingContext(ctx); len(md) != 0 {
		log.Debugf("TEST_APM got header from ctx", md)
		for _, value := range md["x-track-id"] {
			if value != "" {
				return value
			}
		}
	}
	return ""
}
```

## 调用端接收 gRPC 的 Header

在服务端添加代码写入 Header：

```go
func (s *DemoServer) DemoHandler(ctx context.Context, req *DemoSrvRequest) (*DemoResp, error) {
    // some handle logic...
    header := metadata.New(map[string]string{
        "x-data": "data...",
    })
    // 发送 Header 帧
    if e := grpc.SendHeader(ctx, header); e != nil {
        log.Errorf("sending header failed with msg %s", e.Error())
    }
    return result, nil
}
```

在客户端添加代码接收服务端返回的 Header：

```go
	var respHeader metadata.MD
    // 调用 gRPC 服务，接收 Header 的关键在 grpc.Header(&respHeader) 的 opts 的传入
	resp, err = demoCli.DemoHandler(ctx, &req, append(defaultOpts, grpc.Header(&respHeader))...)
	if nil != err && err != redis.Nil {
		log.Errorf("getService callId=%s, error: %s", callID, err)
		return nil, err
	}

	for _, txData := range respHeader["x-data"] {
		// got x-data header
	}
```
