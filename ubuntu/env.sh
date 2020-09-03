#!/usr/bin/env bash
set -e

home=/usr/local/soft
mkdir -p $home
cd $home

if [ -z "`command -v wget`" ];then
  apt install -y wget
fi
apt -y install openssl libssl-dev libpcre3 libpcre3-dev zlib1g-dev g++ make

installJDK(){
    if [ ! -f jdk-8u151-linux-x64.tar.gz ];then
    wget https://repo.huaweicloud.com/java/jdk/8u151-b12/jdk-8u151-linux-x64.tar.gz
    fi

    tar zxvf jdk-8u151-linux-x64.tar.gz
    mv jdk1.8.0_151 /usr/local/java

    javaEnvFile=/etc/profile.d/java.sh
    rm -rf $javaEnvFile
    echo -e '
export JAVA_HOME=/usr/local/java
export PATH=$JAVA_HOME/bin:$PATH
' >> $javaEnvFile
    source $javaEnvFile
}

installNginx(){
    cd $home

    if [ ! -f nginx-1.18.0.tar.gz ];then
    wget https://mirrors.huaweicloud.com/nginx/nginx-1.18.0.tar.gz
    fi

    tar zxvf nginx-1.18.0.tar.gz
    cd nginx-1.18.0
    ./configure --prefix=/usr/local/nginx --with-http_ssl_module
    make && make install
    rm -rf /usr/bin/nginx
    ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
}

installMySql(){
  cd $home
  sudo apt -y install mysql-server
#   service mysqld start

  # 修改密码 添加远程连接权限
  mysql --connect-expired-password -u root -e "
      use mysql;
      update user set authentication_string=PASSWORD("${mysqlPassword}") where user='root';
      update user set plugin="mysql_native_password";
      GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY "${mysqlPassword}" WITH GRANT OPTION;
      flush privileges;
      show databases;
      "
    if [ ! -f /etc/mysql/mysql.conf.d/mysqld.cnf.bak ];then
        cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf.bak
    fi
    if [ ! -f /etc/mysql/conf.d/mysql.cnf.bak ];then
        cp /etc/mysql/conf.d/mysql.cnf /etc/mysql/conf.d/mysql.cnf.bak
    fi
    sudo sed -i "s|^bind-address|#bind-address|" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s|^\[mysqld\]$|\[mysqld\]\ncharacter_set_server=utf8|" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s|^\[mysql\]$|\[mysql\]\ndefault-character-set=utf8|" /etc/mysql/conf.d/mysql.cnf
    service mysql restart
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

  sed -i "/^alias redis=.*$/d" ~/.bashrc
  echo -e "\nalias redis='cd $(pwd)'" >> ~/.bashrc
  source ~/.bashrc
  
  rm -rf /usr/bin/redis-server
  ln -s $(pwd)/src/redis-server /usr/bin/redis-server
  rm -rf /usr/bin/redis-cli
  ln -s $(pwd)/src/redis-cli /usr/bin/redis-cli
}

installJDK
installNginx
installMySql
installRedis