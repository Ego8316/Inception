#!/bin/bash

set -e

WP_DIR=/var/www/html/wordpress

mkdir -p /var/run/vsftpd/empty
mkdir -p "$WP_DIR"

WWW_UID=$(id -u www-data)
WWW_GID=$(id -g www-data)

if ! id "$FTP_USER" >/dev/null 2>&1; then
	useradd -o -u "$WWW_UID" -g "$WWW_GID" -d /var/www/html/wordpress \
		-s /bin/bash "$FTP_USER"
fi
echo "${FTP_USER}:${FTP_PASS}" | chpasswd

echo "$FTP_USER" > /etc/vsftpd.userlist

CUR_UID=$(stat -c '%u' "$WP_DIR")
CUR_GID=$(stat -c '%g' "$WP_DIR")
if [ "$CUR_UID" != "$WWW_UID" ] || [ "$CUR_GID" != "$WWW_GID" ]; then
	echo "[ftp] Fixing ownership on $WP_DIR"
	chown -R "$WWW_UID:$WWW_GID" "$WP_DIR"
fi

if [ -f "/vsftpd.conf.template" ]; then
	echo "[ftp] Setting up configuration"
	envsubst '${FTP_PASV_ADDRESS} ${FTP_PASV_MIN} ${FTP_PASV_MAX}' \
		< /vsftpd.conf.template > /etc/vsftpd.conf
	rm /vsftpd.conf.template
fi

exec vsftpd /etc/vsftpd.conf
