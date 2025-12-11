#!/bin/bash
set -e

DB_HOST=${DB_HOST:-mariadb}
DB_PORT=${DB_PORT:-3306}

cd /var/www/html/wordpress

echo "[wordpress] Waiting for MariaDB"
for i in {30..1}; do
  if mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u"$DB_USER" -p"$DB_PSWD" --silent; then
    break
  fi
  echo "[wordpress] MariaDB not ready, retrying... ($i attempts left)"
  sleep 1
done
if ! mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u"$DB_USER" -p"$DB_PSWD" --silent; then
  echo "[wordpress] MariaDB did not become ready"; exit 1
fi

echo "[wordpress] MariaDB is ready"

if [ ! -f wp-config.php ]; then
  echo "[wordpress] Downloading WordPress core"
  wp core download --allow-root
  echo "[wordpress] Creating wp-config.php"
  wp config create --allow-root \
    --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PSWD" --dbhost="${DB_HOST}:${DB_PORT}"
fi

if ! wp core is-installed --allow-root; then
  echo "[wordpress] Running wp core install"
  wp core install --allow-root \
    --url="$WP_URL" --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PSWD" --admin_email="$WP_ADMIN_EMAIL"
fi

if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
  echo "[wordpress] Creating secondary user $WP_USER"
  wp user create "$WP_USER" "$WP_USER_EMAIL" --allow-root \
    --role=author --user_pass="$WP_USER_PSWD"
fi

echo "[wordpress] Fixing ownership"
chown -R www-data:www-data /var/www/html/wordpress

echo "[wordpress] Configuring php-fpm to listen on 9000"
mkdir -p /run/php
sed -i 's|^listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf

PHP_FPM_BIN=$(command -v php-fpm7.4 || command -v php-fpm)
echo "[wordpress] Starting php-fpm: $PHP_FPM_BIN"
exec "$PHP_FPM_BIN" -F
