#!/usr/bin/env bash
set -e

configSSH(){
    configFile=/etc/ssh/sshd_config
    sed -i "s|^#PermitRootLogin prohibit-password$|PermitRootLogin yes|" $configFile
    service sshd restart
}

configSSH

