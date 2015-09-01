Install Yii
# 1. Install composer.
# 	a. `curl -sS https://getcomposer.org/installer | php`
# (the first time is failed, but second is success.)
# 	b. `sudo mv composer.phar /usr/local/bin/composer`
# 2. Get the PHP's localhost folder with Terminal and type:
# 	`composer create-project --prefer-dist yiisoft/yii2-app-basic basic`
# 	to get down the yii2.
# 	Prompt: "Your requirements could not be resolved to an installable set of packages."


the method above can't install easily.

# 1. Install basic version as below:
1. Install and config your nginx successfully.
2. Download the link "Yii2的基本应用程序模板" from the website "http://www.yiichina.com/download".
	It actually download the source "...".

# 2. Install Advanced version as below:

+ First, do not use the composer to install the yii.
+ Just to download the Advance package.
+ It's the 'yii-advanced-app-2.0.6.tgz' at this git.
+ Unzip it at your localhost(now) folder. There is use "/home/user/workshop/"
+ Then at the advanced folder, use `./init` to init it. select '0';
+ Change your Nginx configure.
+ The file "default" At "/etc/nginx/sites-enabled/".
+ The # is the last localhost, after this, the localhost will change.

<pre>
#server {
#    root /home/user/workshop;
#    index index.html index.htm index.php;
#    server_name localhost;
#
#    location ~ \.php$ {
#        fastcgi_split_path_info ^(.+\.php)(/.+)$;
#        fastcgi_pass unix:/var/run/php5-fpm.sock;
#        fastcgi_index index.php;
#        include fastcgi_params;
#        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
#    }
#}    # above is the config about yii's basic.
## below is the yii's advance

  server {
    charset utf-8;
    client_max_body_size 128M;

    listen 80;
    server_name localhost;
    root    /home/user/workshop/advanced/frontend/web;
    index    index.php;

    access_log  /home/user/workshop/advanced/frontend/log/access.log;
    error_log   /home/user/workshop/advanced/frontend/log/error.log;

    location / {
      try_files $uri $uri/ /index.php?$args;
    }

  #    location ~ \.php$ {
  #    include fastcgi.conf;
  #    fastcgi_pass   127.0.0.1:9000;
  #  }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.(ht|svn|git) {
      deny all;
    }
  }

  server {
    listen 81;
    server_name localhost;
    root /home/user/workshop/advanced/frontend/web;
  }

<pre>

+ Then you should follow above to new the folder 'log' and the file 'access.log', 'error.log';
+ You can see the 'error.log' at the folder "/var/log/nginx/" to see what's error if there was.

+ restart your nginx with "sudo service nginx reload" or use "restart" instead "reload".
