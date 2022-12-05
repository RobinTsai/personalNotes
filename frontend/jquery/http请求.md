# http 请求

## 全局设置

```js
// 全局设置，禁用缓存、使用授权、错误处理函数
$.ajaxSetup({
    cache: false, // 禁用 cache，实质是在 uri 上加参数 _=时间戳（本地磁盘也有缓存）
    xhrFields:{
        withCredentials: true, // 携带授权信息，如 cookie
    },
    error: function (xhr, exception) {
        if (xhr.status === 401) {
            window.location.href = "/" // 任意 api 401 后重定向
        }
    }
})

let origin = window.location.origin

// 发送 GET 方法并获取返回 html 修改后加载到 dom
$.get(origin+"/api/dumps/", function (resp) {
    let as = $(resp).find("a")  // 将结果直接作为 html 查询子元素
    $.each(as, function (i, d){ // 遍历子元素
        let filename = $(d).html() // 获取子元素中的值
        let ele = "some_tml_string".replaceAll('{filename}', filename)
        $("#dumps-list").append(ele) // 动态添加元素
    })
    console.log("new pre: ", as)
})

// 发送 post 方法
$.post(origin+"/api/script/run", JSON.stringify(data),  function (res) {
        console.log("got result", res)
})

// 发送 DELETE 方法
$.ajax({
    url: origin+"/api/dumps",
    type: "DELETE",
    data: JSON.stringify({
        "files": files,
    }),
    success: function() {
        // reload something
    }
})
```
