# fun_bind.coffee


Account = (customer, cart) ->
  @customer = customer
  @cart = cart

  $('.shopping_cart').bind 'click', (event) =>
    @customer.purchase @cart

###
这个例子有点看不懂
而且这个例子暂时还不能来测试
因为着用到了Jquery和CSS
可以编译程JS去看看JS的代码
