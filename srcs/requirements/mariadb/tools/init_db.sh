#!/bin/bash

# Read passwords from Docker secrets (files mounted at /run/secrets/)
# This way passwords are never hardcoded anywhere
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Only run setup if the database hasn't been initialized yet
# /var/lib/mysql/mysql is created by mysql_install_db
if [ ! -d "/var/lib/mysql/mysql" ]; then

    # Initialize the MariaDB data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Run setup SQL before fully starting MariaDB
    # --bootstrap means MariaDB runs the SQL then exits
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

-- Set the root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Create the WordPress database
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

-- Create the WordPress user (% means from any host/container)
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

-- Give that user full access to the WordPress database
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

fi

# Start MariaDB as the main process (PID 1)
# exec replaces this shell — no background processes, no infinite loops
# --bind-address=0.0.0.0 lets other containers connect to us
exec mysqld --user=mysql --bind-address=0.0.0.0