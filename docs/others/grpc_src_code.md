# 从 helloworld 阅读 GRPC-GO 源码

阅读 [grpc-go/helloworld](https://github.com/grpc/grpc-go/tree/master/examples/helloworld) 的源码，看服务是怎么处理程序的。时间及实践关系，先不纠结更深层的。

## Client 端部分

通过 protobuf 能生成 XXXClient 接口。接口对应的是实现的方法，如：

```go
type GreeterClient interface {
	// Sends a greeting
	SayHello(ctx context.Context, in *HelloRequest, opts ...grpc.CallOption) (*HelloReply, error)
}
```

但 `GreeterClient` 这个接口不够通用，所以用 **嵌入接口** 的方式让 `GreeterClient` 接口实现了更底层的 `grpc.ClientConnInterface` 接口：

```go
type greeterClient struct {
	cc grpc.ClientConnInterface
}

func NewGreeterClient(cc grpc.ClientConnInterface) GreeterClient {
	return &greeterClient{cc}
}
```

客户端就是通过 `grpc.ClientConnInterface` 的封装进行与服务端访问的

- cc 对象是创建连接时生成的 conn：`conn, err := grpc.DialContext(*addr, opts...)`
- 访问入口：`c.cc.Invoke(ctx, "/helloworld.Greeter/SayHello", in, out, opts...)`

### grpc.DialContext

`grpc.DialContext` 方法签名：`func DialContext(ctx context.Context, target string, opts ...DialOption) (conn *ClientConn, err error)`

- `DialOptions` 有丰富的类型，在 dialoptions.go 中，可控制
	- 读/写 buffer 的大小
	- 初始流窗口的大小
	- 初始连接窗口的大小
	- 最大消息体的大小
	- 设置压缩/解压方式
	- 设置 ServiceConfig（弃用 opt 方式了，改为 name resolver 方式使用）
	- 设置拦截器（Unary 的和 Stream 式的）
	- 是否 block
	- 等等
- target 是个地址，可以是 DNS resolver 地址，用于根据域名解析到真实的服务 IP 地址
- *此处见下方 Resolver 工作原理*
- DialContext 根据是否 `WithBlock()` 获取一个连接然后返回。非阻塞式在此时不会获取连接
- 以上就是 连接 的初始化过程

### Resolver 工作原理

要注意以下几点：
- 1. 如何从域名找到一个服务地址（连接的服务是多个 IP 映射到同一个 domain 中的）
- 2. 如果运行过程中连接的服务挂了，如何换另一台机器 IP 连接

- 通过 `DialContext()` 函数传入 target 指定待解析的域名地址
- 通过 `ParseTarget()` 函数解析 target
- `cc.getResolver()` 根据 `parsedTarget.Scheme` 获取 resolver.Builder
	- rb 是通过 `WithResolvers() DialOption` 注册进来的，若没注册会查找内置的 scheme 对应的 rb
	- Builder 是个接口，包含一个获取 scheme 的 `Scheme` 函数和一个构建 Resolver 的 `Build` 函数
	- 如有 `dnsBuilder`，能解析配置的固定 IP:port 或 DNS 地址，固有的 IP+port 会返回一个 deadResolver，这里不再考虑
- `dnsBuilder` 通过 Build 方法构建出一个 Resolver 接口的实例，并且会开启一个 watcher 协程每 30s 更新一次地址
- `builder.Build()` 解析到的地址会通过 `cc.UpdateState()` 函数存储并更新
- `cc.UpdateState()` 结束会通过 `updateResolverState()` 触发 `firstResolveEvent` 事件，在 Invoke 的 SendMsg 中会等此事件完成（chan）才发送请求

### c.cc.Invoke

经过拦截器后，会进入 invoke 函数：

```Go
func invoke(ctx context.Context, method string, req, reply interface{}, cc *ClientConn, opts ...CallOption) error {
	cs, err := newClientStream(ctx, unaryStreamDesc, cc, method, opts...)
	if err != nil {
		return err
	}
	if err := cs.SendMsg(req); err != nil {
		return err
	}
	return cs.RecvMsg(reply)
}
```

- `newClientStream` 函数会阻塞等待 resolverBuilder 的 `firstResolveEvent` 事件触发
- ... (会获取一个连接)
- SendMsg
- RecvMsg

## Server 端部分

```go
// server is used to implement helloworld.GreeterServer.
type server struct {
	pb.UnimplementedGreeterServer
}

// SayHello implements helloworld.GreeterServer
func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) {
	log.Printf("Received: %v", in.GetName())
	return &pb.HelloReply{Message: "Hello " + in.GetName()}, nil
}

func main() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port)) // 初始化监听
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()                            // 启动一个 grpc 的空服务
	pb.RegisterGreeterServer(s, &server{})           // 将 greeter server 的一个实例注册到 grpc server 中
	log.Printf("server listening at %v", lis.Addr()) //
	if err := s.Serve(lis); err != nil {             // grpc server 开启服务
		log.Fatalf("failed to serve: %v", err)
	}
}
```

grpc server 的结构（可以看一下，但当前先略看，重点看一下 greet server 的结构）：

```go
type Server struct {
    // Server is a gRPC server to serve RPC requests.
	opts serverOptions

	mu  sync.Mutex // 锁
	lis map[net.Listener]bool

	conns    map[string]map[transport.ServerTransport]bool // conns 会记录每一个监听端口服务上的每一个连接
	serve    bool                                          // 是否开启了服务
	drain    bool                    // 标记是否所有的处理协程都完成，用于优雅退出（drain: 排出）
	cv       *sync.Cond              // signaled when connections close for GracefulStop
	services map[string]*serviceInfo // service name -> service info
	events   trace.EventLog

	quit               *grpcsync.Event
	done               *grpcsync.Event
	channelzRemoveOnce sync.Once
	serveWG            sync.WaitGroup // counts active Serve goroutines for GracefulStop

	channelzID *channelz.Identifier
	czData     *channelzData

	serverWorkerChannels []chan *serverWorkerData
}
```

在上方 `pb.RegisterGreeterServer(s, &server{})` 中注册了 `&server{}`。 这个 `&server{}` 即注册服务的一个实例。其上挂着方法 `func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) `


请求进来时会进入 `s.serveStreams(st)`，其中有 `st.HandleStreams(func1, func2)` 方法。其中 func1 是包含主要处理程序

```go
// func1
func(stream *transport.Stream) {
    wg.Add(1)
    if s.opts.numServerWorkers > 0 {
        data := &serverWorkerData{st: st, wg: &wg, stream: stream}
        select {
        // 将数据放入固定 worker 池（初始化Server 的时候创建的）中，最后还是调用 s.handleStream()
        case s.serverWorkerChannels[atomic.AddUint32(&roundRobinCounter, 1)%s.opts.numServerWorkers] <- data:
        default: // worker 中如果已满开户新协程执行
            go func() {
                s.handleStream(st, stream, s.traceInfo(st, stream))
                wg.Done()
            }()
        }
    } else {
        go func() {
            defer wg.Done()
            s.handleStream(st, stream, s.traceInfo(st, stream))
        }()
    }
}
```

`s.handleStream()`

```go
func (s *Server) handleStream(t transport.ServerTransport, stream *transport.Stream, trInfo *traceInfo) {
	sm := stream.Method() // /helloworld.Greeter/SayHello
	if sm != "" && sm[0] == '/' { // 除去首行 /
		sm = sm[1:]
	}
	pos := strings.LastIndex(sm, "/")
	// ...
	service := sm[:pos]  // helloworld.Greeter
	method := sm[pos+1:] // SayHello

	srv, knownService := s.services[service] // 初始化时注册到此处（见下方注册逻辑）
	if knownService {
		if md, ok := srv.methods[method]; ok { // 方法
			s.processUnaryRPC(t, stream, srv, md, trInfo) // 最后调用此方法，md 为 MethodDesc{MethodName, Handler}
			return
		}
		if sd, ok := srv.streams[method]; ok { // 流式方法
			s.processStreamingRPC(t, stream, srv, sd, trInfo)
			return
		}
	}
	// ...
}
```

注册服务逻辑：

```go
var Greeter_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "helloworld.Greeter",
	HandlerType: (*GreeterServer)(nil),
	Methods: []grpc.MethodDesc{
		{
			MethodName: "SayHello",
			Handler:    _Greeter_SayHello_Handler,
		},
	},
	Streams:  []grpc.StreamDesc{},
	Metadata: "examples/helloworld/helloworld/helloworld.proto",
}

// ss 即 &server{} 即 greeter server 的一个实例（包含 SayHello() 和 mustEmbedUnimplementedGreeterServer()）
func (s *Server) RegisterService(sd *ServiceDesc, ss interface{}) {
	if ss != nil {
		ht := reflect.TypeOf(sd.HandlerType).Elem()
		st := reflect.TypeOf(ss)
		if !st.Implements(ht) { // 判断是否实现了方法
			logger.Fatalf("grpc: Server.RegisterService found the handler of type %v that does not satisfy %v", st, ht)
		}
	}
	s.register(sd, ss) // 注册
}

func (s *Server) register(sd *ServiceDesc, ss interface{}) {
	// ...
	info := &serviceInfo{
		serviceImpl: ss,
		methods:     make(map[string]*MethodDesc),
		streams:     make(map[string]*StreamDesc),
		mdata:       sd.Metadata,
	}
	for i := range sd.Methods {
		d := &sd.Methods[i]
		info.methods[d.MethodName] = d // 注册 Methods，和 Streams 分别注册
	}
	for i := range sd.Streams {
		d := &sd.Streams[i]
		info.streams[d.StreamName] = d // 注册 Streams
	}
	s.services[sd.ServiceName] = info
}
```

最后调用 `s.processUnaryRPC(t, stream, srv, md, trInfo)` 执行函数，此函数比较复杂，当前有些看不懂，似乎在前面是解析（包含解压）数据最后调了 `md.Handler(info.serviceImpl, ctx, df, s.opts.unaryInt)` 方法，即 `_Greeter_SayHello_Handler`


其中 md 是 grpc.MethodDesc

```go
grpc.MethodDesc{
    MethodName: "SayHello",
    Handler:    _Greeter_SayHello_Handler,
},
```

```go
func _Greeter_SayHello_Handler(srv interface{}, ctx context.Context, dec func(interface{}) error, interceptor grpc.UnaryServerInterceptor) (interface{}, error) {
	in := new(HelloRequest)
	if err := dec(in); err != nil { // 此方法会解析 tcp 的数据到 in 中，是在 processUnaryRPC 中定义的
		return nil, err
	}
	if interceptor == nil {
		return srv.(GreeterServer).SayHello(ctx, in) // 没有拦截器的时候直接执行函数
	}
	info := &grpc.UnaryServerInfo{
		Server:     srv,
		FullMethod: "/helloworld.Greeter/SayHello",
	}
	handler := func(ctx context.Context, req interface{}) (interface{}, error) {
		return srv.(GreeterServer).SayHello(ctx, req.(*HelloRequest))
	}
	return interceptor(ctx, in, info, handler) // 执行拦截器函数，并最后传入 handler
}
```

`interceptor` 是 `serverOptions{}.chainUnaryInts` 是在 NewServer 的时候可以设置的拦截器。


# 如何使用 Header

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
