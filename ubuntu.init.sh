#!/usr/bin/env bash
set -e

modifySourcesList(){
    sudo cp -a /etc/apt/sources.list /etc/apt/sources.list.bak

    sudo sed -i "s@http://.*archive.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list
    sudo sed -i "s@http://.*security.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list
    apt-get update
}

configSSH(){
    configFile=/etc/ssh/sshd_config
    sed -i "s|^#PermitRootLogin prohibit-password$|PermitRootLogin yes|" $configFile
    # sed -i "s|^#PubkeyAuthentication yes$|PubkeyAuthentication yes|" $configFile
    sed -i "s|^#Port 22$|Port 22|" $configFile
    service sshd restart
}

modifyDNS(){
    configFile=/etc/systemd/resolved.conf
    sed -i "s|^#DNS=$|DNS=223.5.5.5 223.6.6.6|" $configFile
}

modifySourcesList
configSSH
modifyDNS

