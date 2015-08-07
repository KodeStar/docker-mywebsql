#!/bin/bash

if [ ! -f "$MARIADB_DIR/my.cnf" ];then
cp /defaults/my.cnf "$MARIADB_DIR"/my.cnf
chown abc:abc "$MARIADB_DIR"/my.cnf
chmod 666 "$MARIADB_DIR"/my.cnf
fi

cp "$MARIADB_DIR"/my.cnf /etc/mysql/my.cnf

