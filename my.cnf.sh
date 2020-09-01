#!/usr/bin/env bash
set -e

echo -e "
character_set_server=utf8
collation-server=utf8_general_ci

[client]


[mysql]
default_character_set=utf8
" >> /etc/my.cnf

cat /etc/my.cnf
service mysqld restart