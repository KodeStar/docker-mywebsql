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

# set what to display if no password set with variable MYSQL_ROOT_PASSWORD
NOPASS_SET='/tmp/no-pass.nfo'
cat > $NOPASS_SET <<-EOFPASS
#################################################################
# No root password or too short a password ,min of 4 characters #
# No root password will be set, this is not a good thing        #
# You shoud set one after initialisation with the command       #
#          mysqladmin -u root password <PASSWORD>               #
#################################################################
EOFPASS

# test for empty password variable, if it's set to 0 or less than 4 characters
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
THE_PASS_TEST="0"
else
THE_PASS_TEST="$MYSQL_ROOT_PASSWORD"
fi
TEST_LEN=${#THE_PASS_TEST}
if [ "$TEST_LEN" -lt "4" ]; then
MYSQL_PASS="CREATE USER 'root'@'%' IDENTIFIED BY '' ;"
else
MYSQL_PASS="CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;"
fi

# add rest of sql commands based on password set or not
echo "$MYSQL_PASS" >> "$tempSqlFile"
echo "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;" >> "$tempSqlFile"
echo "DROP DATABASE IF EXISTS test ;" >> "$tempSqlFile"

echo "Setting Up Initial Databases"

# set some permissions needed before we begin initialising
chown -R abc:abc /config/log/mysql /var/run/mysqld
chmod -R 777 /config/log/mysql /var/run/mysqld

# initialise database structure
mysql_install_db --datadir="$DATADIR"

# start mysql and apply our sql commands we set above
start_mysql

# shut down after apply sql commands, waiting for pid to stop
mysqladmin -u root shutdown
wait "$pid"
echo "Database Setup Conpleted"

# display a message about password if not set or too short
if [ "$TEST_LEN" -lt "4" ]; then
echo >&2 "$(cat /tmp/no-pass.nfo)"
sleep 5s
fi

# do some more owning to finish our first run sequence
chown -R abc:abc "$MYSQL_DIR" /config/log/mysql
fi

# own the folder the pid for mysql runs in
chown -R abc:abc /var/run/mysqld


# clean up any old install files from /tmp
if [ -f "/tmp/no-pass.nfo" ]; then
rm /tmp/no-pass.nfo
fi

if [ -f "/tmp/mysql-first-time.sql" ]; then
rm /tmp/mysql-first-time.sql
fi
