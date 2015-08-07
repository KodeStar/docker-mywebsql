#!/bin/bash
if [ ! -f "/config/my.cnf" ];then
cp /etc/mysql/my.cnf /config/my.cnf
chown abc:abc /config/my.cnf
fi

cp /config/my.cnf /etc/mysql/my.cnf
