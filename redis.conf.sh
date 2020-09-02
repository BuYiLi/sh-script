#!/usr/bin/env bash
set -e

read -p "Please input password(Aa@qq.com)" password
    if [ -z "$password" ];then
        password="Aa@qq.com"
    fi

read -p "Please input port(6379)" port
    if [ -z "$port" ];then
        port="6379"
    fi


redisConf=/usr/local/soft/redis/redis.conf

if [ ! -f $redisConf.default ];then
    cp $redisConf $redisConf.default
fi
sed -i "s|^bind 127.0.0.1|#bind 127.0.0.1|" $redisConf
sed -i "s|^daemonize no|daemonize yes|" $redisConf
sed -i "s|^# requirepass foobared|requirepass $password|" $redisConf
sed -i "s|^port 6379|port $port|" $redisConf
sed -i "s|^protected-mode yes|protected-mode no|" $redisConf