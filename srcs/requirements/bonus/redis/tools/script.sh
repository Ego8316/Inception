#!/bin/bash

set -e

if [ -f "/redis.conf.template" ]; then
	echo "[redis] Setting up configuration"
	envsubst '${RE_PSWD}' < /redis.conf.template > /etc/redis/redis.conf
	rm redis.conf.template
fi

echo "[redis] Starting redis"

exec redis-server /etc/redis/redis.conf
