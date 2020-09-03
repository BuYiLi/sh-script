#!/usr/bin/env bash
set -e

configSSH(){
    configFile=/etc/ssh/sshd_config
    sed -i "s|^#PermitRootLogin prohibit-password$|PermitRootLogin yes|" $configFile
    sed -i "s|^#Port 22$|Port 22|" $configFile
    service sshd restart
}

modifyDNS(){
    configFile=/etc/systemd/resolved.conf
    sed -i "s|^#DNS=$|DNS=223.5.5.5 223.6.6.6|" $configFile
}

configSSH
modifyDNS

