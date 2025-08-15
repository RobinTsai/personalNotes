// 此方法改写原生 JSON.parse 方法，在执行 parse 之前加日志输出，并打断点
// 可以在浏览器中执行，在不刷新页面的情况下，看到后续 json 解析的所有参数
// 限制：（部分网站不知道什么原因，看不到输出）
var ori_parser = JSON.parse;
JSON.parse = function(params) {
    console.log("json parse params:", params);
    debugger;
    return ori_parser(params);
};


// 在 F12，网络请求等资源上右键选择“替代内容”，会跳转到“源代码” Tab 弹出关联本地的一个文件夹（也可以在这里发起替代）
// 编辑这里的替代文件信息（记得保存才能生效）
// 可以替代的内容包括：请求标头（Header）、请求响应、js 代码
