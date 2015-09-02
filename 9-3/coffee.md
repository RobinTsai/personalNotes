# offee.md

+ http://coffee-script.org/#usage
+ http://www.ibm.com/developerworks/cn/web/wa-coffee1/

## How to run

### method 1

+ Input `coffee -h` to see the help doc.
+ New a file named a.coffee. And input:
```coffee
  for i in [0..5]
    console.log "Hello #{i}"
```

# sigle line comment
###
  multi-line comment
###
+ At this folder's Terminal and input `coffee a.coffee`
+ It runs output the information.

+ To see what you have write with JavaScript.
+ You can input `coffee -c a.coffee` to compile it to an 'a.js' file.

+ New a file named b.coffee. And input:
```coffee
  stdin = process.openStdin()
  stdin.setEncoding 'utf8'
  stdin.on 'data', (input) ->
      name = input.trim()
      process.exit() if name == 'exit'
      console.log "Hello #{name}"
      console.log "Enter another name or 'exit' to exit"
  console.log 'Enter your name'
```

+ Don't use `alert` there, you can't.


### Method 2: REPL

+ Input `coffee` at one Terminal window.
+ There you can try some little codes.
+ Try to input `nums = [1..10]` and press Enter. Output 1-10.
+ `isOdd = (n) -> n % 2 == 1`, output '[Function]'
+ `odds = nums.filter isOdd`, output '[1, 3, 5, 7, 9]'
+ `odds.reduce (a,b) -> a + b`, out put '25'
