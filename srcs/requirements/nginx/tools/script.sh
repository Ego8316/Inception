#!/bin/bash

set -e

log() {
	echo "[nginx] $*"
}

if [ -f "/default.conf.template" ]; then
	log "Setting up configuration"
	envsubst '${WP_DOMAIN}' < /default.conf.template > /etc/nginx/conf.d/default.conf
	rm default.conf.template
fi

if [ ! -d "/etc/nginx/ssl" ]; then
	log "Generating SSL certificate"
	mkdir -p /etc/nginx/ssl
	openssl req -x509 \
				-nodes \
				-days 365 \
				-newkey rsa:2048 \
				-keyout /etc/nginx/ssl/key.pem \
				-out /etc/nginx/ssl/cert.pem \
				-subj "/CN=${WP_DOMAIN}"
fi

log "Starting nginx"

exec nginx -g "daemon off;"
