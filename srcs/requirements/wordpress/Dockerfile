FROM		debian:bullseye

RUN			apt-get update -y && \
			apt-get install -y php php-fpm php-mysql \
			php-curl php-xml php-zip php-gd php-intl \
			mariadb-client curl	&& \
			rm -rf /var/lib/apt/lists/* && \
			curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
			chmod +x wp-cli.phar && \
			mv wp-cli.phar /usr/bin/wp

COPY		./tools/script.sh /entrypoint.sh
RUN			chmod +x /entrypoint.sh

RUN			mkdir -p /var/www/html/wordpress
WORKDIR		/var/www/html/wordpress
EXPOSE		9000

ENTRYPOINT	[ "/entrypoint.sh" ]