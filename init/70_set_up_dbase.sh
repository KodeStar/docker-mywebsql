#!/bin/bash
start_mysql(){
mysqld --init-file="$tempSqlFile" &
pid="$!"
RET=1
while [[ RET -ne 0 ]]; do
mysql -uroot -e "status" > /dev/null 2>&1
RET=$?
sleep 1
done
}

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

if [ ! -d "$DATADIR/mysql" ]; then
tempSqlFile='/tmp/mysql-first-time.sql'
cat > "$tempSqlFile" <<-EOSQL
DELETE FROM mysql.user ;
CREATE USER 'root'@'%' IDENTIFIED BY '' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOSQL
echo "Setting Up Initial Databases"
chown -R abc:abc /config/log/mariadb /var/run/mysqld
chmod -R 777 /config/log/mariadb /var/run/mysqld
mysql_install_db --datadir="$DATADIR"
start_mysql
mysqladmin -u root shutdown
wait "$pid"
chown -R abc:abc "$MARIADB_DIR" /config/log/mariadb
echo "Database Setup Conpleted"
fi

chown -R abc:abc /var/run/mysqld

