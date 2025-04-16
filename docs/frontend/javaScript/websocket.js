let ws = new WebSocket("ws://"+host+"/api/ws");

// 定义心跳对象控制心跳
let heartbeat = {
    timeout: 30000,   // 30s 无交互超时
    timeoutObj: null, // 延时处理函数
    reset: function () { // 重置心跳倒计时
        clearTimeout(this.timeoutObj);
        this.start();  // 开启
    },
    start: function() {
        // 延时发送请求——心跳
        this.timeoutObj = setTimeout(function() {
            ws.send("ping");
        }, this.timeout)
    }
};

// 在建立连接时启动心跳
ws.onopen = function () {
    heartbeat.start()
}

// 在收到交互信息时重置心跳
ws.onmessage = function ( msg ) {
    console.log("received from ws:", msg)
    if (msg.type !== "message") {
        return
    }

    heartbeat.reset()
    if (msg.data === "pong") {
        return;
    }

    // do with meaningful message response
}
