#!/usr/bin/env bash
set -e

home=/usr/local/soft
mkdir -p $home
cd $home

if [ -z "`command -v wget`" ];then
  apt install -y wget
fi
apt -y install openssl libssl-dev libpcre3 libpcre3-dev zlib1g-dev g++

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

# installJDK
installNginx