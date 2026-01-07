#!/bin/bash

set -e

log() {
	echo "[redis] $*"
}

if [ -f "/redis.conf.template" ]; then
	log "Setting up configuration"
	envsubst '${RE_PSWD}' < /redis.conf.template > /etc/redis/redis.conf
	rm redis.conf.template
fi

log "Starting redis"

exec redis-server /etc/redis/redis.conf
