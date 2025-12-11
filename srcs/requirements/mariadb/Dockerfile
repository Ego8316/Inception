FROM		debian:bullseye

RUN			apt-get update -y && \
			apt-get install -y mariadb-server && \
			rm -rf /var/lib/apt/lists/*

RUN			mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY		./tools/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY		./tools/script.sh /entrypoint.sh
RUN			chmod +x /entrypoint.sh

EXPOSE		3306

ENTRYPOINT	["/entrypoint.sh"]