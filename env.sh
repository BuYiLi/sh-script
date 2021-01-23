#!/usr/bin/env bash
set -e

defaultMysqlPassword="Password123@qq.com"
readonly defaultMysqlPassword
mysqlPassword=""

read_mysql_var(){
  if [ -z "$mysqlPassword" ];then
    read -p "Please input mysql password(${defaultMysqlPassword})" mysqlPassword
      if [ -z "$mysqlPassword" ];then
          mysqlPassword=${defaultMysqlPassword}
      fi
  fi
}



home=/usr/local/soft
mkdir -p $home
cd $home

if [ -z "`command -v wget`" ];then
  yum install -y wget
fi
yum install -y zlib-devel pcre-devel openssl openssl-devel gcc-c++

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

installJDKWithBinary(){
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
    tar zxvf nginx-1.18.0.tar.gz
  fi
  cd nginx-1.18.0
  ./configure --prefix=/usr/local/nginx --with-http_ssl_module
  make && make install
  rm -rf /usr/bin/nginx
  ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
}

installMySql(){
  read_mysql_var
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

  sed -i "/^alias redis=.*$/d" ~/.bashrc
  echo -e "\nalias redis='cd $(pwd)'" >> ~/.bashrc
  source ~/.bashrc
  
  rm -rf /usr/bin/redis-server
  ln -s $(pwd)/src/redis-server /usr/bin/redis-server
  rm -rf /usr/bin/redis-cli
  ln -s $(pwd)/src/redis-cli /usr/bin/redis-cli
}

installJDKWithBinary
installNginx
installMySql
installRedis

echo -e "install JDK complete!!!"
echo -e "run follow command:"
echo -e "\t" "source $javaEnvFile"


env_help() {
    echo ShadowSocksR python client tool
    echo -e if you have not installed env, run \`env install\` first
    echo Usage:
    echo -e "\t" "env help"
    echo -e "\n" "Install/Uninstall"
    echo -e "\t" "env mysql       install mysql"
    echo -e "\t" "env nginx       install nginx"
    echo -e "\t" "env redis       install redis"
    echo -e "\t" "env jdk-bin         install java development kit with binary"
    echo -e "\t" "env jdk-package         install java development kit with package"
    echo -e "\n" "Config and Subscribe"
    echo -e "\t" "env update       update subscription from $WEBSITE"
    echo -e "\t" "env config       edit config.json"
    echo -e "\t" "env xclip        paste configs from clipboard to config.json"
    echo -e "\n" "Start/Stop/Restart"
    echo -e "\t" "env start        start the shadowsocks service"
    echo -e "\t" "env stop         stop the shadowsocks service"
    echo -e "\t" "env restart      restart the shadowsocks service"
    echo -e "\n" "Testing and Maintenance"
    echo -e "\t" "env test         get ip from cip.cc using socks5 proxy"
    echo -e "\t" "env log          cat the log of shadowsocks"
    echo -e "\t" "env shell        cd into env installation dir"
    echo -e "\t" "env clean        clean env configuration backups"
}

env_main() {
    case $1 in
        help)           env_help                    ;;
        mysql)          installMySql                ;;
        nginx)          installNginx                ;;
        redis)          installRedis                ;;
        jdk-bin)        installJDKWithBinary        ;;
        jdk-package)    installJDK                  ;;
        start)          env_start                   ;;
        stop)           env_stop                    ;;
        restart)        env_restart                 ;;
        test)           env_test                    ;;
        log)            env_log                     ;;
        shell)          env_shell                   ;;
        clean)          env_clean                   ;;
        *)              env_help                    ;;
    esac
}

env_main $1