## Services
This stack provides:
- NGINX (TLS entrypoint on 443) serving WordPress.
- WordPress with php-fpm.
- MariaDB database for WordPress.

Optional bonus services:
- Redis cache for WordPress.
- Adminer database UI.
- FTP access to the WordPress files.
- Static site served on port 8081.
- MariaDB backup service.
- Dashboard status page.

## Start and stop the project
- Start and build: `make` or `make up`
- Stop (keep containers): `make stop`
- Stop and remove containers: `make down`
- Full cleanup (removes data): `make fclean`

## Access the website and administration panel
- Main site: `https://hcavet.42.fr`
- WordPress admin: `https://hcavet.42.fr/wp-admin`
- Adminer (bonus): `http://hcavet.42.fr:8080`
- Static site (bonus): `http://hcavet.42.fr:8081`
- Dashboard (bonus): `http://hcavet.42.fr:8082`
- FTP (bonus): connect to `hcavet.42.fr` on port 21

## Credentials
- All credentials and configuration values are stored in `srcs/.env`.
- Copy `srcs/.env.example` to `srcs/.env` and fill values before running.
- Do not commit `srcs/.env` to git (it contains secrets).

## Check services and health
- Quick status: `make status`
- Compose status: `docker compose -f srcs/docker-compose.yml ps`
- Logs: `make logs` or `docker compose -f srcs/docker-compose.yml logs -f`
- Dashboard (bonus): `http://hcavet.42.fr:8082` shows service reachability.
