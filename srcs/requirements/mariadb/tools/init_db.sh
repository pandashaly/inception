#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
# read passwords from my secrets files
# this way passwords are never hardcoded anywhere

# check that database hasn't been initialized yet then RUN
# /var/lib/mysql/mysql is created by mysql_install_db
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi
# we're creating a database called wordpress,
# and a user ssottori with the password panda
# who has full access to it.
# WordPress will use those credentials to connect. (secrets)

# start the process (pid1) exec replaces this shell
# --bind-address=0.0.0.0 lets other containers connect to us
sed -i 's/^skip-networking/#skip-networking/' /etc/my.cnf.d/mariadb-server.cnf
exec mysqld --user=mysql --bind-address=0.0.0.0