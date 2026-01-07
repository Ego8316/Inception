FROM		debian:bullseye

RUN			apt-get update -y && \
			apt-get install -y nginx && \
			rm -rf /var/lib/apt/lists/* && \
			rm -f /etc/nginx/sites-enabled/default && \
			rm -f /var/www/html/index.nginx-debian.html

COPY		./site/ /var/www/site/
COPY		./tools/default.conf /etc/nginx/conf.d/default.conf

EXPOSE		8081

ENTRYPOINT	[ "nginx", "-g", "daemon off;" ]
