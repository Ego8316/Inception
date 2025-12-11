FROM		debian:bullseye

RUN			apt-get update -y && \
			apt-get install -y nginx openssl gettext-base && \
			rm -rf /var/lib/apt/lists/* && \
			rm -f /etc/nginx/sites-enabled/default && \
			rm -f /var/www/html/index.nginx-debian.html

COPY		./tools/default.conf /default.conf.template
COPY		./tools/script.sh /entrypoint.sh
RUN			chmod +x /entrypoint.sh

EXPOSE		443

ENTRYPOINT	["/entrypoint.sh"]
