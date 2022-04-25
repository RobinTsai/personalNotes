# 从 helloworld 阅读 GRPC-GO 源码

阅读 [grpc-go/helloworld](https://github.com/grpc/grpc-go/tree/master/examples/helloworld) 的源码，看服务是怎么处理程序的。时间及实践关系，先不纠结更深层的。

## Server

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

在上方 `pb.RegisterGreeterServer(s, &server{})` 中注册了 `&server{}` 这个 `&server{}` 即注册服务的一个实例。其上挂着方法 `func (s *server) SayHello(ctx context.Context, in *pb.HelloRequest) (*pb.HelloReply, error) `


请求进来时会进入 `s.serveStreams(st)`，其中有 `st.HandleStreams(func1, func2)` 方法。其中 func1 是包含主要处理程序

```go
// func1
func(stream *transport.Stream) {
    wg.Add(1)
    if s.opts.numServerWorkers > 0 {
        data := &serverWorkerData{st: st, wg: &wg, stream: stream}
        select {
        case s.serverWorkerChannels[atomic.AddUint32(&roundRobinCounter, 1)%s.opts.numServerWorkers] <- data: // 将数据放入固定 worker 池（初始化Server 的时候创建的）中，最后还是调用 s.handleStream()
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