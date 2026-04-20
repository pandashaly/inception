#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php83/php-fpm.d/www.conf

until nc -w1 mariadb 3306 </dev/null >/dev/null 2>&1; do
    sleep 2
done

mkdir -p /var/www/html
cd /var/www/html

if [ ! -f wp-config.php ]; then
    wp core download --allow-root --quiet
    wp config create --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASSWORD}" --dbhost=mariadb --allow-root
    wp core install --url="https://${DOMAIN_NAME}" --title="${WP_ADMIN_TITLE}" --admin_user="${WP_ADMIN_LOGIN}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}" --skip-email --allow-root
    wp user create "${WP_USER_LOGIN}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASSWORD}" --role=author --allow-root
fi

exec php-fpm83 -F