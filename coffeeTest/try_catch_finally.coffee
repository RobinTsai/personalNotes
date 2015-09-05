# try_catch_finally.coffee

tryfunction = ->
  console.log "try..."
cleanup = ->
  console.log "clean..."

try
  tryfunction()
catch error
  print error       # 这里现在还不能测试，知道流程好了
finally
  cleanup()

### =>
try...
clean...
###
