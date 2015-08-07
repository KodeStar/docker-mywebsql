#!/bin/bash

if [ ! -f "/config/www/mywebsql/index.php" ]; then
echo "fetching mywebsql files"
rm /config/www/index.html
cd /config/www
cp /defaults/mywebsql /config/nginx/site-confs/default
wget http://sourceforge.net/projects/mywebsql/files/latest/download -O mywebsql.zip >/dev/null 2>&1
unzip mywebsql.zip
rm mywebsql.zip
chown -R abc:abc /config/www/mywebsql
fi

if [ ! "$ stat -c %a /etc/mysql/debian.cnf" = "644" ]; then
chmod 644 /etc/mysql/debian.cnf
fi
