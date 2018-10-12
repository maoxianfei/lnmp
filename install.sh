#/bin/bash
#Create by Mxf at 2018-09-04

if [ -z "$1" ];then
        echo -e "\033[32m lnmp install shell \033[1m"
        echo "1)编译安装Nginx-1.14.0"
        echo "2)编译安装php-5.6.37"
        echo "3)编译安装reids-4.0.11"
        echo "4)编译安装glibc-2.15"
        echo "5)编译安装jdk-8u65"
        echo "6)编译安装node4.2.3"
        echo "7)编译安装phpredis-4.1.1"
        echo "8)编译安装"
        echo -e "\033[31mUsage: { /bin/sh $0 1|2|3|4|5|6|7 help}\033[0m"
        exit
fi

#NGINX Install info
NGINX_FILE=nginx-1.14.0.tar.gz
NGINX_FILE_DIR=nginx-1.14.0
if [ "$1" -eq "1" ];then
		yum install -y gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel --setopt=protected_multilib=false;
	if [ $? -eq 0 ];then
		groupadd -g 888 www;
		useradd -g www www -s /sbin/nologin -u 888;
		tar zxvf $NGINX_FILE;
		cd $NGINX_FILE_DIR;
		if [ $? -eq 0 ];then
		./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-stream_ssl_module --with-http_ssl_module --with-stream;
			if [ $? -eq 0 ];then
				make && make install;
				echo "\033[32m $NGINX_FILE_DIR install success \033[0m"
				 if [ $? -eq 0 ];then
				 	cd ../
				 	cp init.d.nginx /etc/init.d/nginx
				 	chmod 777 /etc/init.d/nginx
				 	sed -i '65,71s/#//' /usr/local/nginx/conf/nginx.conf
				 	sed -i '66s/html/\/var\/www\/html/' /usr/local/nginx/conf/nginx.conf
				 	sed -i 's/scripts$fastcgi_script_name/$document_root$fastcgi_script_name/g' /usr/local/nginx/conf/nginx.conf
				 	echo "\033[32m $NGINX_FILE_DIR install done \033[0m"
				 else
				 	echo "\033[32m conf moddify failed \033[0m"
				 fi
			else
				echo "\033[32m make install failed \033[0m"
				exit 0
			fi
		else
			echo "\033[32m configure failed \033[0m"
			exit 0
		fi
	fi
fi	


#PHP Install info
PHP_FILE=php-5.6.37.tar.gz
PHP_FILE_DIR=php-5.6.37


if [ "$1" -eq "2" ];then
	yum -y install openssl openssl-devel curl curl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel pcre pcre-devel libxslt libxslt-devel bzip2 bzip2-devel readline-devel libicu-devel;
	if [ $? -eq 0 ];then
		tar zxvf libmcrypt-2.5.7.tar.gz;
		cd libmcrypt-2.5.7;
		./configure --prefix=/usr/local/libmcrypt;
		make && make install;
		if [ $? -eq 0 ];then
			cd ..;
			tar zxvf $PHP_FILE;
			cd $PHP_FILE_DIR;
			./configure --prefix=/usr/local/php --with-fpm-group=www --with-fpm-user=www --with-config-file-path=/usr/local/php/etc --with-png-dir=/usr/local/libpng --with-jpeg-dir=/usr/local/jpeg --with-freetype-dir=/usr/local/freetype --with-zlib-dir=/usr/local/zlib --with-mcrypt=/usr/local/libmcrypt --with-libxml-dir=/usr/local/libxml2/ --with-iconv-dir=/usr/local/libiconv --enable-libxml --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-opcache --enable-mbregex --enable-fpm --enable-mbstring=all --enable-gd-native-ttf --with-openssl --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --without-pear --with-gettext --enable-session --with-curl --enable-ctype --enable-shared --with-gd
			make && make install;
			if [ $? -eq 0 ];then
				cp /soft/sogood_lnmp/php-5.6.37/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
				cp /soft/sogood_lnmp/php-5.6.37/sapi/fpm/php-fpm.conf /usr/local/php/etc/php-fpm.conf
				cp /soft/sogood_lnmp/php-5.6.37/php.ini-production /usr/local/php/etc/php.ini
				chmod 777 /etc/init.d/php-fpm
				ln -s /usr/local/php/bin/php /usr/bin/php
			else
				echo "\033[32m php config failed \033[0m"
				exit 0

			fi
		else
			echo "\033[32m php configure|make|make install failed \033[0m"
			exit 0
		fi

	else 
		echo "\033[32m libmcrypt configure|make failed \033[0m"
		exit 0
	fi

fi


REDIS_FILE=redis-4.0.11.tar.gz
REIDS_DIR=redis-4.0.11
#redis
if [ "$1" -eq "3 " ];then
	yum install autoconf;
	#start download
	echo -e "\033[32m Download redis now... \033[0m"
	#wget http://download.redis.io/releases/redis-4.0.10.tar.gz
	if [ $? -eq "0" ];then
		echo -e "\033[32m Download redis success \033[0m"
	else
		echo -e "\033[31m Download redis fail \033[0m"
	fi
	tar xvf $REDIS_FILE
	if [ $? -eq "0" ];then
		mv $REIDS_DIR /usr/local/redis
		if [ $? -eq "0" ];then
			cd /usr/local/redis
			make
			if [ $? -eq "0" ];then
				ln -s /usr/local/redis/src/redis-cli /usr/bin/redis-cli
				sed -i 's/daemonize no/daemonize yes/g' /usr/local/redis/redis.conf
				sed -i 's/^# bind 127.0.0.1/bind 127.0.0.1/g' /usr/local/redis/redis.conf
				echo -e "\033[32m  phpredis install start \033[0m"
			else
				echo -e "\033[31m redis install fail \033[0m"
			fi	
		else
			echo -e "\033[31m move redis fail \033[0m"
		fi
	else
		echo -e "\033[31m tar redis fail \033[0m"
	fi	
fi


#Glibc Install
G_FILES=glibc-2.15.tar.gz
G_FILES_DIR=glibc-2.15
GP_FILES=glibc-ports-2.15.tar.gz
GP_FILES_DIR=glibc-ports-2.15
#Install Glibc
if [[ "$1" -eq "4" ]];then
      tar -zxvf $G_FILES && tar -zxvf $GP_FILES && mv $GP_FILES_DIR $G_FILES_DIR/ports && cd $G_FILES_DIR && mkdir -p glibc-build-2.15 && cd glibc-build-2.15 && ../configure  --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
    if [ $? -eq 0 ];then
       make && make install
        echo -e "\n\033[32m-----------------------------------------------\033[0m"
         echo -e "\033[32mThe $G_FILES_DIR Server Install Success !\033[0m"
       else
         echo -e "\033[32mThe $G_FILES_DIR  install ERROR,Please Check......"
    fi
fi


#JDK Install
J_FILES=jdk-8u65-linux-x64.rpm
#Install JDK
if [[ "$1" -eq "5" ]];then
        rpm -ivh $J_FILES
    if [ $? -eq 0 ];then
         echo -e "\n\033[32m-----------------------------------------------\033[0m"
         echo -e "\033[32mThe $J_FILES Server Install Success !\033[0m"
    else
         echo -e "\033[32mThe $J_FILES RPM install ERROR,Please Check......"
  fi
fi

#Node Install
NODE_FILES=node-v4.2.3-linux-x64.tar.gz
NODE_FILES_DIR=node-v4.2.3-linux-x64
NODE_PREFIX=/usr/local/node
#https://github.com/foreverjs/forever
F_FILES_DIR=forever


#Install NODE server
if [[ "$1" -eq "6" ]];then
      tar xvf $NODE_FILES && mv $NODE_FILES_DIR $NODE_PREFIX && ln -s $NODE_PREFIX/bin/node /usr/bin      
        if [ $? -eq 0 ];then
                cp -ra $F_FILES_DIR $NODE_PREFIX/lib/node_modules && chmod -R 777 $NODE_PREFIX/lib/node_modules/$F_FILES_DIR && ln -s $NODE_PREFIX/lib/node_modules/$F_FILES_DIR/bin/$F_FILES_DIR /usr/bin
                echo -e "\n\033[32m-----------------------------------------------\033[0m"
                echo -e "\033[32mThe $NODE_FILES_DIR Server Install Success !\033[0m"
               
        else
                echo -e "\033[32mThe $NODE_FILES_DIR Make or Make install ERROR,Please Check......"
                exit 0
        fi
fi

#Install phpredis-4.1.1 server
if [[ "$1" -eq "7" ]];then

	tar zxvf phpredis-4.1.1.tar.gz;
	cd phpredis-4.1.1;
	if [ $? -eq 0 ];then
		/usr/local/php/bin/phpize;
		./configure --with-php-config=/usr/local/php/bin/php-config;
		make;
		make install;
		if [ $? -eq 0 ];then
			echo "extension=\"redis.so\"" >> /usr/local/php/etc/php.ini
			echo -e "\033[32m phpredis install success,please restart php-fpm"
		fi
	else
		echo -e "\033[32m phpredis make ERROR Please Check......"
	fi


fi
