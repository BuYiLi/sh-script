#!/usr/bin/env bash
set -e

read -p "Please input mysql password(Password123@qq.com)" mysqlPassword
    if [ -z "$mysqlPassword" ];then
        mysqlPassword="Password123@qq.com"
    fi

home=/usr/local/soft
mkdir -p $home
cd $home

if [ -z "`command -v wget`" ];then
  yum install -y wget
fi

installJDK(){
  cd $home
  # i586
  #wget https://repo.huaweicloud.com/java/jdk/8u151-b12/jdk-8u151-linux-i586.rpm
  #yum localinstall -y jdk-8u151-linux-i586.rpm

  #x64
  if [ ! -f jdk-8u151-linux-x64.rpm ];then
  wget https://repo.huaweicloud.com/java/jdk/8u151-b12/jdk-8u151-linux-x64.rpm
  fi
  yum localinstall -y jdk-8u151-linux-x64.rpm
}

installNginx(){
  cd $home
  yum install -y zlib-devel pcre-devel openssl openssl-devel gcc-c++
  if [ ! -f nginx-1.18.0.tar.gz ];then
    wget https://mirrors.huaweicloud.com/nginx/nginx-1.18.0.tar.gz
    tar zxvf nginx-1.18.0.tar.gz
  fi
  cd nginx-1.18.0
  ./configure --prefix=/usr/local/nginx --with-http_ssl_module
  make && make install
  rm -rf /usr/bin/nginx
  ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
}

installMySql(){
  cd $home
  if [ ! -f mysql57-community-release-el7-8.noarch.rpm ];then
    wget https://repo.mysql.com//mysql57-community-release-el7-8.noarch.rpm
  fi
  if [ -z "`yum list | grep mysql57-community-release.noarch`" ];then
    yum -y install mysql57-community-release-el7-8.noarch.rpm
  fi
  yum -y install mysql-community-server
  service mysqld start
  initPassword=$(grep 'temporary password' /var/log/mysqld.log | awk -F "root@localhost: " '{print $2}')

  # 修改密码 添加远程连接权限
  mysql --connect-expired-password -u root -p"${initPassword}" -e "
      SET PASSWORD = PASSWORD('${mysqlPassword}');
      use mysql;
      GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${mysqlPassword}' WITH GRANT OPTION;
      flush privileges;
      show databases;
      "
}

installRedis(){
  cd $home
  if [ ! -f redis-5.0.3.tar.gz ];then
    wget https://mirrors.huaweicloud.com/redis/redis-5.0.3.tar.gz
  fi
  tar zxvf redis-5.0.3.tar.gz
  mv redis-5.0.3 redis
  cd redis
  make
  rm -rf /usr/bin/redis-server
  ln -s $(pwd)/src/redis-server /usr/bin/redis-server
  rm -rf /usr/bin/redis-cli
  ln -s $(pwd)/src/redis-cli /usr/bin/redis-cli
}

installJDK
installNginx
installMySql
installRedis