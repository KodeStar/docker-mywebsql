#!/bin/bash
if [ ! -d "$DATADIR/mysql" ]; then
echo "Setting Up Initial Databases"
mkdir -p "$DATADIR" /config/log/mariadb /var/run/mysqld
chmod -R 777 /var/run/mysqld
mysql_install_db --datadir="$DATADIR" >/dev/null 2>&1

tempSqlFile='/tmp/mysql-first-time.sql'
cat > "$tempSqlFile" <<-EOSQL
DELETE FROM mysql.user ;
CREATE USER 'root'@'%' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOSQL
mysqld --init-file="$tempSqlFile" >/dev/null 2>&1 &
chown -R abc:abc "$MARIADB_DIR" "$DATADIR" /config/log/mariadb /var/run/mysqld
echo "Database Setup Conpleted"
fi


