#!/bin/bash

if [ ! -d "/config/log/mariadb" ]; then
mkdir -p /config/log/mariadb
fi


if [ ! -d "$DATADIR" ]; then
mkdir -p $DATADIR
fi

if [ ! -d "/var/run/mysqld" ]; then
mkdir -p /var/run/mysqld
chmod -R 777 /var/run/mysqld
fi
