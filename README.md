<p align="center">
  <img src="https://github.com/Ego8316/Ego8316/blob/main/42-badges/born2beroot.png" height="150" alt="42 Born2beroot Badge"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/42-Project-blue" height="32"/>
  <img src="https://img.shields.io/github/languages/code-size/Ego8316/get_next_line?color=5BCFFF" height="32"/>
</p>

# Inception

### 🎓 42 School – Final Grade: **125/100**

Dockerized web stack for 42’s Inception project, combining mandatory services
(WordPress, NGINX, MariaDB) plus optional bonuses (Redis, Adminer, FTP,
static site, backup, dashboard).

## 📦 What’s in this repo
- `srcs/docker-compose.yml` and custom service Dockerfiles.
- Entry-point scripts that perform first-run bootstrap.
- `Makefile` helpers for build/startup/cleanup.
- A `.env`-driven configuration model from `srcs/.env.example`.

## ✅ Prerequisites
- Docker Engine + Docker Compose plugin
- Linux environment with subject-compliant VM constraints
- Permission to edit `/etc/hosts` and run Docker without root

## 🧱 Stack overview
Mandatory services:
- **NGINX**: TLS entrypoint only on `443`.
- **WordPress**: PHP-FPM only (`9000`) for app logic.
- **MariaDB**: stores WordPress data.

Optional bonus services:
- Redis cache (WordPress), Adminer, FTP, static site, backup worker, dashboard.

## ⚡ Quick start
1. Map domain in `/etc/hosts`:
   - `127.0.0.1 login.42.fr`
2. Copy and fill env file:
   - `cp srcs/.env.example srcs/.env`
3. Optional: if data path differs, set `Makefile` login target `/home/<login>/data`.
4. Start:
   - `make` or `make up`
5. Open: `https://login.42.fr`

## 🔧 Service bootstrap (condensed)
- **NGINX**: renders vhost from template + creates TLS cert if absent.
- **WordPress**: waits for MariaDB (and Redis), builds `wp-config.php`, installs
  WordPress if needed, creates users, enables Redis cache plugin.
- **MariaDB**: initializes datadir, applies bootstrap SQL, sets root/database/user,
  then runs foreground mysqld.
- **Redis**: writes redis config from env and starts daemonized-off mode.
- **Adminer**: serves Adminer through PHP built-in server on `8080`.
- **FTP**: creates configured FTP user/list and passive mode conf, serves
  `/var/www/html/wordpress`.
- **Static site**: serves static content from `/var/www/site` on `8081`.
- **Backup**: runs periodic mysqldump-based jobs through cron into `/var/log/db-backup.log`.
- **Dashboard**: renders a live service reachability page on `8082`.

## 🛠️ Common workflow
- Start: `make` / `make up`
- Status: `make status`
- Logs: `make logs`
- Stop: `make stop`
- Remove containers: `make down`
- Remove containers + volumes: `make clean`
- Full cleanup (incl. `/home/login/data`): `make fclean`
- Shell: `docker exec -it <container_name> bash`

## 🗄️ Persistence and data
Named volumes under `/home/login/data`:
- `wordpress-data` -> `/home/login/data/wordpress`
- `mariadb-data` -> `/home/login/data/mariadb`
- `backup-data` -> `/home/login/data/backup`

## 🌐 Access points
- Main site: `https://login.42.fr`
- Admin: `https://login.42.fr/wp-admin`
- Adminer: `http://login.42.fr:8080`
- Static site: `http://login.42.fr:8081`
- Dashboard: `http://login.42.fr:8082`
- FTP: `login.42.fr:21`

## 📄 License
MIT — see `LICENSE`.
