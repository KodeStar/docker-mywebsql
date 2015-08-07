#!/bin/bash
if [ ! -d "$MARIADB_DIR" ]; then
mkdir "$MARIADB_DIR"
fi

if [ ! -f "$MARIADB_DIR/my.cnf" ];then
cp /defaults/my.cnf "$MARIADB_DIR"/my.cnf
chown abc:abc "$MARIADB_DIR"/my.cnf
chmod 666 "$MARIADB_DIR"/my.cnf
fi

sed -i -e 's#\(log_error.*=\).*#\1 /config/log/mariadb/mysql_safe.log#g' "$MARIADB_DIR"/my.cnf
sed -i -e 's/\(user.*=\).*/\1 abc/g' "$MARIADB_DIR"/my.cnf
sed -i -e "s#\(datadir.*=\).*#\1 $DATADIR#g" "$MARIADB_DIR"/my.cnf
cp "$MARIADB_DIR"/my.cnf /etc/mysql/my.cnf

