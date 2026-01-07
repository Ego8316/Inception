FROM		debian:bullseye

RUN			apt-get update -y && \
			DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-client cron gzip tzdata socat && \
			rm -rf /var/lib/apt/lists/*

COPY		./tools/backup.sh /usr/local/bin/backup.sh
COPY		./tools/script.sh /entrypoint.sh
RUN			chmod +x /usr/local/bin/backup.sh /entrypoint.sh

EXPOSE		3307

ENTRYPOINT	[ "/entrypoint.sh" ]
