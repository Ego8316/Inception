FROM		debian:bullseye

RUN			apt-get update -y && \
			apt-get install -y redis-server gettext-base && \
			rm -rf /var/lib/apt/lists/*

COPY		./tools/redis.conf /redis.conf.template
COPY		./tools/script.sh /entrypoint.sh
RUN			chmod +x /entrypoint.sh

EXPOSE		6379

ENTRYPOINT	[ "/entrypoint.sh" ]
