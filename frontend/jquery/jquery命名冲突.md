# jquery 命名冲突

当在编写油猴插件的时候，可能会有插件定义的 jquery 与页面其他 jquery 定义冲突。
可以在插件前使用以下方式重新定义 jquery。

```js
// 解决和原网页jquery版本冲突
var jq = jQuery.noConflict(true);

(function(jq) { /* 使用 jq 代替 $ */ })(jq)
```
