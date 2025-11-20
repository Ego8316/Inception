#!/bin/bash

# sleep 100000
service mariadb start

mariadb -u root -e "CREATE DATABASE IF NOT EXISTS wordpress; "
mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '12345';"
mariadb -u root -p12345 -e "CREATE USER IF NOT EXISTS 'wp'@'%' IDENTIFIED BY 'wp1234';"
mariadb -u root -p12345 -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wp'@'%';"
mariadb -u root -p12345 -e "FLUSH PRIVILEGES;"
kill $(cat /var/run/mysqld/mysqld.pid)
mysqld