FROM		debian:bullseye

RUN			apt-get update -y && \
			apt-get install -y vsftpd gettext-base && \
			rm -rf /var/lib/apt/lists/*

COPY		./tools/vsftpd.conf /vsftpd.conf.template
COPY		./tools/script.sh /entrypoint.sh
RUN			chmod +x /entrypoint.sh

EXPOSE		21

ENTRYPOINT	[ "/entrypoint.sh" ]
