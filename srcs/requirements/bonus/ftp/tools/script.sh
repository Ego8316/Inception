#!/bin/bash

set -e

WP_DIR=/var/www/html/wordpress

log() {
	echo "[ftp] $*"
}

log "Bootstrapping vsftpd"

mkdir -p /var/run/vsftpd/empty
mkdir -p "$WP_DIR"

log "Using data dir: $WP_DIR"

WWW_UID=$(id -u www-data)
WWW_GID=$(id -g www-data)

if ! id "$FTP_USER" >/dev/null 2>&1; then
	log "Adding user $FTP_USER (uid=$WWW_UID gid=$WWW_GID)"
	useradd -o -u "$WWW_UID" -g "$WWW_GID" -d /var/www/html/wordpress \
		-s /bin/bash "$FTP_USER"
fi

echo "${FTP_USER}:${FTP_PASS}" | chpasswd
log "Password updated for $FTP_USER"

log "Writing userlist"
echo "$FTP_USER" > /etc/vsftpd.userlist

CUR_UID=$(stat -c '%u' "$WP_DIR")
CUR_GID=$(stat -c '%g' "$WP_DIR")
if [ "$CUR_UID" != "$WWW_UID" ] || [ "$CUR_GID" != "$WWW_GID" ]; then
	log "Fixing ownership on $WP_DIR"
	chown -R "$WWW_UID:$WWW_GID" "$WP_DIR"
fi

if [ -f "/vsftpd.conf.template" ]; then
	log "Setting up configuration"
	envsubst '${FTP_PASV_ADDRESS} ${FTP_PASV_MIN} ${FTP_PASV_MAX}' \
		< /vsftpd.conf.template > /etc/vsftpd.conf
	rm /vsftpd.conf.template
	log "Config ready (pasv ${FTP_PASV_ADDRESS}:${FTP_PASV_MIN}-${FTP_PASV_MAX})"
fi

log "Starting FTP server"

exec vsftpd /etc/vsftpd.conf
