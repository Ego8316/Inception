#!/bin/bash

set -e

DATADIR=/var/lib/mysql
SOCKET=/run/mysqld/mysqld.sock
INIT_MARKER="$DATADIR/.init_done"

if [ ! -d "$DATADIR/mysql" ]; then
  echo "[mariadb] Initializing datadir"
  mariadb-install-db --user=mysql --datadir="$DATADIR"
fi

echo "[mariadb] Starting mysqld in background for preflight"
mysqld_safe --datadir="$DATADIR" --socket="$SOCKET" --user=mysql &

echo "[mariadb] Waiting for mysqld to start"
for i in {30..1}; do
  mysqladmin ping --socket="$SOCKET" --silent && break
  sleep 1
done

if ! mysqladmin ping --socket="$SOCKET" --silent; then
  echo "[mariadb] mysqld failed to start"; exit 1
fi
echo "[mariadb] mysqld successfully started"

if [ ! -f "$INIT_MARKER" ]; then
  echo "[mariadb] Applying bootstrap SQL"
  mariadb --socket="$SOCKET" -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PSWD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL
  touch "$INIT_MARKER"
fi

echo "[mariadb] Stopping background mysqld"
mysqladmin --socket="$SOCKET" -uroot -p"${DB_ROOT}" shutdown

echo "[mariadb] Starting foreground mysqld"
exec mysqld_safe --datadir="$DATADIR" --socket="$SOCKET" --user=mysql
