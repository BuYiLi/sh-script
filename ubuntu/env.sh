#!/usr/bin/env bash
set -e

home=/usr/local/soft
mkdir -p $home
cd $home

if [ -z "`command -v wget`" ];then
  apt install -y wget
fi
sudo apt-get install build-essential zlib1g-dev libpcre3 libpcre3-dev  libssl-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev  libgoogle-perftools-dev libperl-dev libtool libpcrecpp0v5 openssl -y

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