FROM		debian:bullseye

RUN			apt-get update -y && \
			apt-get install -y php php-mysql curl && \
			rm -rf /var/lib/apt/lists/*

RUN			mkdir -p /var/www/html
WORKDIR		/var/www/html
RUN			curl -fsSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
			-o /var/www/html/index.php

COPY		./tools/script.sh /entrypoint.sh
RUN			chmod +x /entrypoint.sh

EXPOSE		8080

ENTRYPOINT	[ "/entrypoint.sh" ]
