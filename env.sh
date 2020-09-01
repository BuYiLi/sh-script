#!/usr/bin/env bash
set -e

mkdir -p /usr/local/soft
cd /usr/local/soft

if [ -z "`yum list | grep wget`" ];then
  yum install -y wget
fi

installJDK(){
  # i586
  #wget https://repo.huaweicloud.com/java/jdk/8u151-b12/jdk-8u151-linux-i586.rpm
  #yum localinstall -y jdk-8u151-linux-i586.rpm

  #x64
  if [ ! -f jdk-8u151-linux-x64.rpm ];then
  wget https://repo.huaweicloud.com/java/jdk/8u151-b12/jdk-8u151-linux-x64.rpm
  fi
  yum localinstall -y jdk-8u151-linux-x64.rpm
  echo 'JDK install complete!======================================'
}

installNginx(){
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
      SET PASSWORD = PASSWORD('Password123@qq.com');
      use mysql;
      GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Password123@qq.com' WITH GRANT OPTION;
      flush privileges;
      show databases;
      "
}

installRedis(){
  if [ ! -f redis-5.0.3.tar.gz ];then
    wget http://download.redis.io/releases/redis-5.0.3.tar.gz
  fi
  tar zxvf redis-5.0.3.tar.gz
  cd redis-5.0.3
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