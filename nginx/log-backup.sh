#!/bin/bash

base_path=/usr/local/logbackup/nginx

store_path=${base_path}/`date -d yesterday +%Y%m`

mkdir -p ${store_path}

backup_log_name=$(date -d yesterday +%Y%m%d%::z).access.log

source_file=/usr/local/nginx/logs/access.log


mv ${source_file} ${store_path}/${backup_log_name}

touch ${source_file}

kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`


