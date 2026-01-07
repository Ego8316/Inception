#!/bin/bash

set -e

log() {
	echo "[adminer] $*"
}

log "Starting Adminer"

exec php -S 0.0.0.0:8080 -t /var/www/html
