#!/bin/bash

set -e

TZ=${TZ:-Europe/Paris}
export TZ

log() {
	echo "[backup] $*"
}

log "Using TZ=$TZ"

mkdir -p "$BACKUP_DIR"
touch /var/log/db-backup.log

SCHEDULE="*/${BACKUP_INTERVAL_MINUTES} * * * *"
log "Scheduling backups: $SCHEDULE"

if command -v socat >/dev/null 2>&1; then
	log "Starting health listener on 3307"
	socat TCP-LISTEN:3307,reuseaddr,fork EXEC:'/bin/true' &
fi

log "Writing cron schedule to /etc/cron.d/db-backup"
cat > /etc/cron.d/db-backup <<EOF
TZ=${TZ}
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
${SCHEDULE} root DB_HOST=${DB_HOST} DB_USER=${DB_USER} DB_PSWD=${DB_PSWD} DB_NAME=${DB_NAME} BACKUP_DIR=${BACKUP_DIR} BACKUP_PREFIX=${BACKUP_PREFIX} BACKUP_KEEP=${BACKUP_KEEP} /usr/local/bin/backup.sh >> /var/log/db-backup.log 2>&1
EOF

chmod 0644 /etc/cron.d/db-backup

log "Starting cron"

exec cron -f
