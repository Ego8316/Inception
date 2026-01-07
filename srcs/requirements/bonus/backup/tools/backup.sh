#!/bin/bash

set -e

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

TS=$(date +"%Y%m%d_%H%M%S")
FILE="${BACKUP_DIR}/${BACKUP_PREFIX}_${TS}.sql.gz"

mkdir -p "$BACKUP_DIR"

log "Starting backup for ${DB_NAME}@${DB_HOST}"

mysqldump \
	-h"$DB_HOST" \
	-u"$DB_USER" \
	-p"$DB_PSWD" \
	--single-transaction \
	--quick \
	"$DB_NAME" | gzip > "$FILE"

log "Backup written to $FILE"

if [ -n "$BACKUP_KEEP" ]; then
	log "Pruning to keep ${BACKUP_KEEP} most recent backups"
	ls -1t "${BACKUP_DIR}/${BACKUP_PREFIX}"_*.sql.gz \
		| tail -n +$((BACKUP_KEEP + 1)) \
		| xargs -r rm -f
fi
