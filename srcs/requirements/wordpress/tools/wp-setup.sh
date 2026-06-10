#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
ADMIN_PASSWORD=$(grep 'ADMIN_PASSWORD' /run/secrets/credentials | cut -d= -f2)
USER_PASSWORD=$(grep 'USER_PASSWORD'  /run/secrets/credentials | cut -d= -f2)

WP_PATH=/var/www/wordpress

echo "[wp-setup] Waiting for MariaDB..."
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done
echo "[wp-setup] MariaDB is up."

cd "${WP_PATH}"

if [ ! -f wp-login.php ]; then
    wp core download --allow-root --locale=en_US
fi

if [ ! -f wp-config.php ]; then
    wp config create \
        --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --path="${WP_PATH}"
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    wp core install \
        --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    wp user create \
        --allow-root \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${USER_PASSWORD}" \
        --role=editor

    echo "[wp-setup] WordPress installed successfully."
fi

# Fix upload permissions
mkdir -p "${WP_PATH}/wp-content/uploads"
chown -R www-data:www-data "${WP_PATH}/wp-content/uploads"
chmod -R 755 "${WP_PATH}/wp-content/uploads"

# Redis cache setup
if ! wp plugin is-installed redis-cache --allow-root 2>/dev/null; then
    wp plugin install redis-cache --activate --allow-root
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp redis enable --allow-root
    echo "[wp-setup] Redis cache enabled."
fi

exec /usr/sbin/php-fpm8.2 --nodaemonize
