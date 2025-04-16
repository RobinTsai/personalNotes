# switch.coffee

# 1.
switch_day = (day) ->
  switch day
    when "Thu" then "go iceFishing"
    when "Fri", "Sat"
      if day is bingoDay    # 在这里只是说明
        "go bingo"
    when "Sun" then "go church"
    else "go work"

doWhat = switch_day "Sun"
console.log doWhat        # => go church

###
  省略了break，他能自动break
  但应该还有不让它break的语句，暂时未知
###

# 2. if_else 的形式
# 在使用swith中可以使用 表达式
score = 75
grade = switch   # 在这里加了score也不错, 但意义上说不通
  when score < 60 then "F"
  when score < 70 then "D"
  when score < 80 then "C"
  when score < 90 then "B"
  else "A"

console.log grade         # C
# 因为省略了break语句
# 所以要注意when的顺序
