## Prerequisites
- Docker Engine and Docker Compose plugin installed.
- A Linux VM as required by the subject.
- Ability to edit `/etc/hosts` and run Docker as your user.

## Setup from scratch
1. Update the login if needed in `Makefile` (used to build `/home/<login>/data`).
2. Map the domain to your local IP in `/etc/hosts`:
   - `127.0.0.1 hcavet.42.fr`
3. Create the environment file:
   - `cp srcs/.env.example srcs/.env`
   - Fill in all values in `srcs/.env`.
4. Optional: create the data folders before running:
   - `make setup` (creates `/home/hcavet/data/{wordpress,mariadb,backup}`)

### Service setup details (script walkthroughs)
The following sections explain how each service is bootstrapped by its entrypoint
script, which files are generated, and which inputs it relies on.

#### NGINX (TLS entrypoint)
File: `srcs/requirements/nginx/tools/script.sh`
- Inputs: `WP_DOMAIN`
- Generated files: `/etc/nginx/conf.d/default.conf`,
  `/etc/nginx/ssl/cert.pem`, `/etc/nginx/ssl/key.pem`
- Steps:
  1. Render the vhost template with `envsubst` into `default.conf`.
  2. Generate a self-signed certificate if missing.
  3. Start NGINX in the foreground (`daemon off;`).

Configuration:
File: `srcs/requirements/nginx/tools/default.conf`
- Purpose: NGINX vhost template for TLS and PHP proxying.
- Key directives: `listen 443 ssl`, `server_name ${WP_DOMAIN}`,
  `ssl_protocols TLSv1.2 TLSv1.3`, `root /var/www/html/wordpress`,
  `fastcgi_pass wordpress:9000`.
- Rendered to: `/etc/nginx/conf.d/default.conf`

#### WordPress (php-fpm)
File: `srcs/requirements/wordpress/tools/script.sh`
- Inputs: `DB_NAME`, `DB_USER`, `DB_PSWD`, `WP_URL`, `WP_TITLE`,
  `WP_ADMIN_USER`, `WP_ADMIN_PSWD`, `WP_ADMIN_EMAIL`,
  `WP_USER`, `WP_USER_EMAIL`, `WP_USER_PSWD`,
  optional `DB_HOST`, `DB_PORT`, `RE_HOST`, `RE_PORT`, `RE_PSWD`
- Generated files: `/var/www/html/wordpress/wp-config.php`
- Steps:
  1. Wait for MariaDB using `mysqladmin ping`.
  2. Download WordPress core on first run.
  3. Create `wp-config.php` with DB connection info.
  4. Wait for Redis, then set `WP_REDIS_*` constants.
  5. Install WordPress if not installed.
  6. Create a secondary user if missing.
  7. Install and enable the Redis cache plugin.
  8. Set php-fpm to listen on port 9000 and start it in the foreground.

Configuration:
File: `/var/www/html/wordpress/wp-config.php` (generated)
- Purpose: WordPress runtime settings and DB connection details.
- Key entries: `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`,
  `WP_REDIS_HOST`, `WP_REDIS_PORT`, `WP_REDIS_PASSWORD`.
File: `/etc/php/7.4/fpm/pool.d/www.conf`
- Purpose: php-fpm pool settings.
- Key change: `listen = 9000` so NGINX can reach php-fpm.

#### MariaDB
File: `srcs/requirements/mariadb/tools/script.sh`
- Inputs: `DB_ROOT`, `DB_NAME`, `DB_USER`, `DB_PSWD`
- Generated files: `/var/lib/mysql/.init_done` (bootstrap marker)
- Steps:
  1. Initialize the datadir on first run with `mariadb-install-db`.
  2. Start `mysqld_safe` in the background and wait for readiness.
  3. Apply bootstrap SQL (root password, database, user, grants).
  4. Shutdown and restart MariaDB in the foreground.

Configuration:
File: `srcs/requirements/mariadb/tools/50-server.cnf`
- Purpose: MariaDB server settings (bind, charset, paths).
- Key settings: `bind-address = 0.0.0.0`, `port = 3306`,
  `datadir = /var/lib/mysql`, `socket = /run/mysqld/mysqld.sock`,
  `character-set-server = utf8mb4`, `collation-server = utf8mb4_general_ci`.
- Copied to: `/etc/mysql/mariadb.conf.d/50-server.cnf`

#### Redis (bonus)
File: `srcs/requirements/bonus/redis/tools/script.sh`
- Inputs: `RE_PSWD`
- Generated files: `/etc/redis/redis.conf`
- Steps:
  1. Render `redis.conf` from the template with the required password.
  2. Start Redis in the foreground.

Configuration:
File: `srcs/requirements/bonus/redis/tools/redis.conf`
- Purpose: Redis server settings with authentication.
- Key settings: `requirepass ${RE_PSWD}`, `bind 0.0.0.0`,
  `protected-mode yes`, `port 6379`, `daemonize no`.
- Rendered to: `/etc/redis/redis.conf`

#### Adminer (bonus)
File: `srcs/requirements/bonus/adminer/tools/script.sh`
- Inputs: none
- Steps:
  1. Start the PHP built-in server on port 8080 serving `/var/www/html`.
Configuration:
File: `/var/www/html/index.php` (Adminer)
- Purpose: Single-file Adminer UI served directly by `php -S`.

#### FTP (bonus)
File: `srcs/requirements/bonus/ftp/tools/script.sh`
- Inputs: `FTP_USER`, `FTP_PASS`, `FTP_PASV_ADDRESS`, `FTP_PASV_MIN`,
  `FTP_PASV_MAX`
- Generated files: `/etc/vsftpd.userlist`, `/etc/vsftpd.conf`
- Steps:
  1. Ensure the WordPress directory exists and map the FTP user to `www-data`
     UID/GID so permissions match the web server.
  2. Set the FTP password and write the user allow list.
  3. Render `vsftpd.conf` with passive mode settings.
  4. Start `vsftpd` in the foreground.

Configuration:
File: `srcs/requirements/bonus/ftp/tools/vsftpd.conf`
- Purpose: vsftpd configuration (local auth + passive mode).
- Key settings: `local_enable=YES`, `write_enable=YES`,
  `chroot_local_user=YES`, `allow_writeable_chroot=YES`,
  `local_root=/var/www/html/wordpress`,
  `pasv_address=${FTP_PASV_ADDRESS}`, `pasv_min_port=${FTP_PASV_MIN}`,
  `pasv_max_port=${FTP_PASV_MAX}`.
- Rendered to: `/etc/vsftpd.conf`
File: `/etc/vsftpd.userlist`
- Purpose: allowed FTP users (contains only `${FTP_USER}`).

#### Static site (bonus)
Files: `srcs/requirements/bonus/static-site/Dockerfile`,
`srcs/requirements/bonus/static-site/tools/default.conf`
- Inputs: none
- Steps:
  1. Copy static HTML/CSS/JS to `/var/www/site`.
  2. Serve it with a minimal NGINX vhost on port 8081.

Configuration:
File: `srcs/requirements/bonus/static-site/tools/default.conf`
- Purpose: NGINX vhost for the static site.
- Key directives: `listen 8081`, `root /var/www/site`,
  `index index.html`, `try_files $uri $uri/ =404`.
- Copied to: `/etc/nginx/conf.d/default.conf`

#### Backup (bonus)
Files: `srcs/requirements/bonus/backup/tools/script.sh`,
`srcs/requirements/bonus/backup/tools/backup.sh`
- Inputs: `DB_HOST`, `DB_USER`, `DB_PSWD`, `DB_NAME`, `BACKUP_DIR`,
  `BACKUP_PREFIX`, `BACKUP_KEEP`, `BACKUP_INTERVAL_MINUTES`, `TZ`
- Generated files: `/etc/cron.d/db-backup`, `/var/log/db-backup.log`
- Steps:
  1. Write a cron schedule that runs every `BACKUP_INTERVAL_MINUTES`.
  2. `backup.sh` runs `mysqldump`, compresses it, and rotates old backups.
  3. Keep cron in the foreground to keep the container alive.

Configuration:
File: `/etc/cron.d/db-backup`
- Purpose: schedule the backup job.
- Key line: runs every `BACKUP_INTERVAL_MINUTES` with DB env vars and
  writes output to `/var/log/db-backup.log`.

#### Dashboard (bonus)
File: `srcs/requirements/bonus/dashboard/tools/dashboard.py`
- Inputs: none
- Steps:
  1. Check service ports and render HTML using `dashboard.html` and `style.css`.
  2. Serve the dashboard on port 8082 (auto-refresh via HTML meta tag).

Configuration:
File: `srcs/requirements/bonus/dashboard/tools/dashboard.html`
- Purpose: HTML template with placeholders `{{ROWS}}`, `{{LINKS}}`,
  and `{{UPDATED}}` filled by the Python server.
File: `srcs/requirements/bonus/dashboard/tools/style.css`
- Purpose: basic styling for the dashboard UI.

## Build and launch
- Standard workflow: `make` or `make up`
- Manual Compose (if you do not use the Makefile):
  - `export DATA_PATH=/home/hcavet/data`
  - `docker compose -f srcs/docker-compose.yml up -d --build`

## Manage containers and volumes
- Status: `make status`
- Logs: `make logs`
- Stop without removing: `make stop`
- Stop and remove containers: `make down`
- Remove containers and volumes: `make clean`
- Full cleanup including `/home/hcavet/data`: `make fclean`
- Shell access: `docker exec -it <container_name> bash`

## Persistence and data locations
Named volumes are used for persistence and store data under `/home/hcavet/data`:
- `wordpress-data` -> `/home/hcavet/data/wordpress` (WordPress files)
- `mariadb-data` -> `/home/hcavet/data/mariadb` (database files)
- `backup-data` -> `/home/hcavet/data/backup` (bonus backups)

## Configuration reference
The following values are required in `srcs/.env`:
- WordPress: `WP_DOMAIN`, `WP_URL`, `WP_TITLE`, `WP_ADMIN_USER`, `WP_ADMIN_PSWD`,
  `WP_ADMIN_EMAIL`, `WP_USER`, `WP_USER_EMAIL`, `WP_USER_PSWD`
- MariaDB: `DB_NAME`, `DB_USER`, `DB_PSWD`, `DB_ROOT`
- Redis (bonus): `RE_PSWD`
- FTP (bonus): `FTP_USER`, `FTP_PASS`, `FTP_PASV_ADDRESS`, `FTP_PASV_MIN`,
  `FTP_PASV_MAX`
- Backup (bonus): `DB_HOST`, `BACKUP_DIR`, `BACKUP_INTERVAL_MINUTES`,
  `BACKUP_PREFIX`, `BACKUP_KEEP`, `TZ`
