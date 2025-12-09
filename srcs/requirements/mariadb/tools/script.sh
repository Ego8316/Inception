#!/bin/bash

echo "[mariadb] Starting MariaDB"
service mariadb start

echo "[mariadb] Configuring MariaDB"
mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';"
mariadb -u root -p"${DB_ROOT}" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mariadb -u root -p"${DB_ROOT}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PSWD}';"
mariadb -u root -p"${DB_ROOT}" -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
mariadb -u root -p"${DB_ROOT}" -e "FLUSH PRIVILEGES;"

echo "[mariadb] Switching to foreground MariaDB daemon"
kill $(cat /var/run/mysqld/mysqld.pid)
exec mysqld