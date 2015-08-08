#!/bin/bash
# set start function that creates user and password, used later
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

# test for existence of mysql file in datadir and start initialise if not present
if [ ! -d "$DATADIR/mysql" ]; then

# set basic sql command
tempSqlFile='/tmp/mysql-first-time.sql'
cat > "$tempSqlFile" <<-EOSQL
DELETE FROM mysql.user ;
EOSQL

# set what to display if no password set with variable MARIA_ROOT_PASSWORD
NOPASS_SET='/tmp/no-pass.nfo'
cat > $NOPASS_SET <<-EOFPASS
######################################################
# Did you forget to add -e MARIA_ROOT_PASSWORD=... ? #
# No root user password , databases will be insecure #
# This is not a good thing  you shoud set one.       #
######################################################
EOFPASS

# test for empty password variable or if it's set to 0
if [ -z "$MARIA_ROOT_PASSWORD" ]; then
echo >&2 "$(cat /tmp/no-pass.nfo)"
sleep 5s
MARIA_PASS="CREATE USER 'root'@'%' IDENTIFIED BY '' ;"
elif [  "$MARIA_ROOT_PASSWORD" -eq "0"  ]; then
echo >&2 "$(cat /tmp/no-pass.nfo)"
sleep 5s
MARIA_PASS="CREATE USER 'root'@'%' IDENTIFIED BY '' ;"
else
MARIA_PASS="CREATE USER 'root'@'%' IDENTIFIED BY '${MARIA_ROOT_PASSWORD}' ;"
fi

# add rest of sql commands based on password set or not
echo "$MARIA_PASS" >> "$tempSqlFile"
echo "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;" >> "$tempSqlFile"
echo "DROP DATABASE IF EXISTS test ;" >> "$tempSqlFile"

echo "Setting Up Initial Databases"

# set some permissions needed before we begin initialising
chown -R abc:abc /config/log/mariadb /var/run/mysqld
chmod -R 777 /config/log/mariadb /var/run/mysqld

# initialise database structure
mysql_install_db --datadir="$DATADIR"

# start mysql and apply our sql commands we set above
start_mysql

# shut down after apply sql commands, waiting for pid to stop
mysqladmin -u root shutdown
wait "$pid"
echo "Database Setup Conpleted"

# do some more owning to finish our first run sequence
chown -R abc:abc "$MARIADB_DIR" /config/log/mariadb
fi

# own the folder the pid for mariadb runs in
chown -R abc:abc /var/run/mysqld


# clean up any old install files from /tmp
if [ -f "/tmp/no-pass.nfo" ]; then
rm /tmp/no-pass.nfo
fi

if [ -f "/tmp/mysql-first-time.sql" ]; then
rm /tmp/mysql-first-time.sql
fi
