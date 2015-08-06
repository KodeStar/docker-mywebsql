#!/bin/bash
if [ ! -d "$DATADIR/mysql" ]; then
mkdir -p /var/run/mysqld
mkdir -p "$DATADIR"
mysql_install_db --datadir="$DATADIR"

tempSqlFile='/tmp/mysql-first-time.sql'
cat > "$tempSqlFile" <<-EOSQL
DELETE FROM mysql.user ;
CREATE USER 'root'@'%' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOSQL
mysqld --init-file="$tempSqlFile"
chown -R abc:abc "$DATADIR" /var/run/mysqld
fi


