# 控制元素 style

- addClass()
- removeClass()
- toggleClass() 添加/删除 class 互相切换
- css() 设置或返回样式属性
- attr("style", "") 设置 style 属性以操作 css
- css("style", "")
- removeAttr()

> 注：attr 是相对于 DOM 元素的属性，如 style；css 是专用于操作样式的，如 style 中的 background-color 属性。

```js
$("p").css("background-color"); // 获取 css
$("p").css("background-color", "red"); // 更新 css
```
