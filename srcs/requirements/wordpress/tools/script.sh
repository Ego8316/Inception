#!/bin/bash

set -e

log() {
	echo "[wordpress] $*"
}

DB_HOST=${DB_HOST:-mariadb}
DB_PORT=${DB_PORT:-3306}
RE_HOST=${RE_HOST:-redis}
RE_PORT=${RE_PORT:-6379}

cd /var/www/html/wordpress

log "Waiting for MariaDB"
for i in {30..1}; do
  if mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u"$DB_USER" -p"$DB_PSWD" --silent; then
    break
  fi
  log "MariaDB not ready, retrying... ($i attempts left)"
  sleep 1
done
if ! mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u"$DB_USER" -p"$DB_PSWD" --silent; then
  log "MariaDB did not become ready"; exit 1
fi

log "MariaDB is ready"

if [ ! -f wp-config.php ]; then
  log "Downloading WordPress core"
  wp core download --allow-root
  log "Creating wp-config.php"
  wp config create --allow-root \
    --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PSWD" --dbhost="${DB_HOST}:${DB_PORT}"
fi

log "Waiting for Redis"
for i in {30..1}; do
  if redis-cli -h "$RE_HOST" -p "$RE_PORT" -a "$RE_PSWD" ping >/dev/null 2>&1; then
    break
  fi
  log "Redis not ready, retrying... ($i attempts left)"
  sleep 1
done
if ! redis-cli -h "$RE_HOST" -p "$RE_PORT" -a "$RE_PSWD" ping >/dev/null 2>&1; then
  log "Redis did not become ready"; exit 1
fi

wp config set WP_REDIS_HOST "$RE_HOST" --allow-root --type=constant
wp config set WP_REDIS_PORT "$RE_PORT" --allow-root --type=constant
wp config set WP_REDIS_PASSWORD "$RE_PSWD" --allow-root --type=constant

if ! wp core is-installed --allow-root; then
  log "Running wp core install"
  wp core install --allow-root \
    --url="$WP_URL" --title="$WP_TITLE" \
    --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PSWD" --admin_email="$WP_ADMIN_EMAIL"
fi

if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
  log "Creating secondary user $WP_USER"
  wp user create "$WP_USER" "$WP_USER_EMAIL" --allow-root \
    --role=author --user_pass="$WP_USER_PSWD"
fi

if ! wp plugin is-installed redis-cache --allow-root; then
  log "Installing redis-cache plugin"
  wp plugin install redis-cache --activate --allow-root
elif ! wp plugin is-active redis-cache --allow-root; then
  wp plugin activate redis-cache --allow-root
fi
wp redis enable --allow-root

log "Fixing ownership"
chown -R www-data:www-data /var/www/html/wordpress

log "Configuring php-fpm to listen on 9000"
mkdir -p /run/php
sed -i 's|^listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf

PHP_FPM_BIN=$(command -v php-fpm7.4 || command -v php-fpm)
log "Starting php-fpm: $PHP_FPM_BIN"
exec "$PHP_FPM_BIN" -F
