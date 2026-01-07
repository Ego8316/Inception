#!/bin/bash

set -e

log() {
	echo "[mariadb] $*"
}

DATADIR=/var/lib/mysql
SOCKET=/run/mysqld/mysqld.sock
INIT_MARKER="$DATADIR/.init_done"

if [ ! -d "$DATADIR/mysql" ]; then
  log "Initializing datadir"
  mariadb-install-db --user=mysql --datadir="$DATADIR"
fi

log "Starting mysqld in background for preflight"
mysqld_safe --datadir="$DATADIR" --socket="$SOCKET" --user=mysql &

log "Waiting for mysqld to start"
for i in {30..1}; do
  mysqladmin ping --socket="$SOCKET" --silent && break
  sleep 1
done

if ! mysqladmin ping --socket="$SOCKET" --silent; then
  log "mysqld failed to start"; exit 1
fi
log "mysqld successfully started"

if [ ! -f "$INIT_MARKER" ]; then
  log "Applying bootstrap SQL"
  mariadb --socket="$SOCKET" -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PSWD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL
  touch "$INIT_MARKER"
fi

log "Stopping background mysqld"
mysqladmin --socket="$SOCKET" -uroot -p"${DB_ROOT}" shutdown

log "Starting foreground mysqld"
exec mysqld_safe --datadir="$DATADIR" --socket="$SOCKET" --user=mysql
