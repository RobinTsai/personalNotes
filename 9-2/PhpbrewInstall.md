# Phpbrew

+ Install use this link: http://cache.baiducontent.com/c?m=9d78d513d9811bed4fece42e4d4192725e14de6c6691965768d5e0558e24041a1b33a6e87b770704a49421381ced131efdf04036604361ecc6949f4aabe4c1747cdd706b2740c05612a55bf58911798537902db3e946b9&p=8c57c25681934eac58ecd72d021489&newp=8770c80c85cc43b408e2977e0c0883231610db2151d6d10e&user=baidu&fm=sc&query=phpbrew&qid=f2064aec00186245&p1=1

+ You need config your Nginx for Yii.
+ Follow the config in the file "install Yii.md"

+ When you input 127.0.0.1 in you URL, it says an error "Bad Gateway".
+ Maybe your fpm is wrong.
+ Try `phpbrew fpm module` to see if you config well.
+ Install as the link above, and you need to attention those commands:
  Add `source ~/.phpbrew/bashrc` to your bashrc.
```shell 
  phpbrew init
  sudo service nginx restart
  phpbrew use 5.6.11
  phpbrew fpm start
```

+ Maybe you need re-run those commands many times to try.
