*This project has been created as part of the 42 curriculum by hcavet.*

## Project Description
Inception builds a small web stack with Docker Compose using custom images from
`srcs/requirements` (and `srcs/requirements/bonus` for optional services). All
images are built from Debian bullseye Dockerfiles, and the services communicate
over a user-defined Docker network. Configuration is provided through
environment variables in `srcs/.env`.

Mandatory services:
- NGINX with TLSv1.2/1.3 as the only public entrypoint on port 443.
- WordPress with php-fpm only (no NGINX).
- MariaDB only (no NGINX).
- Named volumes for the WordPress database and site files.

Bonus services included in this repository:
- Redis cache for WordPress.
- Adminer for database access.
- FTP server pointing at the WordPress files.
- Static site served by NGINX.
- MariaDB backup service.
- Stack dashboard page.

Main design choices:
- Debian bullseye base images for all services, matching the allowed stable versions.
- First-run configuration done in entrypoint scripts (TLS certs, DB bootstrap, WP setup).
- One public entrypoint (NGINX) on 443 with TLSv1.2/1.3.
- Persistent data stored under `/home/hcavet/data` via named volumes.

### Virtual Machines vs Docker
Virtual machines virtualize full operating systems, while Docker containers share
the host kernel and isolate processes. For this stack, containers provide the
needed isolation with far less overhead and faster startup times.

### Secrets vs Environment Variables
Environment variables are simple for configuration but can leak via logs and
process inspection. Docker secrets are safer for sensitive values; this project
uses a `.env` file for configuration and can be extended with secrets if needed.

### Docker Network vs Host Network
A user-defined bridge network provides service discovery and isolation while
allowing container-to-container communication. Host networking removes isolation
and is forbidden by the subject.

### Docker Volumes vs Bind Mounts
Named volumes are managed by Docker and are portable across environments; bind
mounts tie a container to a specific host path. This project uses named volumes
that store their data under `/home/hcavet/data` as required by the subject.

## Instructions
1. Map the domain to your local IP (example entry in `/etc/hosts`):
   - `127.0.0.1 hcavet.42.fr`
2. Copy `srcs/.env.example` to `srcs/.env` and fill in values.
3. Run `make` (or `make up`) from the repository root.
4. Open `https://hcavet.42.fr` in your browser.

Bonus service endpoints (if enabled):
- Adminer: `http://hcavet.42.fr:8080`
- Static site: `http://hcavet.42.fr:8081`
- Dashboard: `http://hcavet.42.fr:8082`
- FTP: connect to port 21 (passive range 21100-21110)

## Resources
- Docker Engine: https://docs.docker.com/engine/
- Docker Compose: https://docs.docker.com/compose/
- NGINX: https://nginx.org/en/docs/
- WordPress and WP-CLI: https://wordpress.org/ and https://wp-cli.org/
- MariaDB: https://mariadb.com/kb/en/documentation/
- Redis: https://redis.io/docs/
- vsftpd: https://security.appspot.com/vsftpd.html
- Adminer: https://www.adminer.org/
- TechWorld with Nana: https://www.youtube.com/watch?v=3c-iBn73dDE
- Fortsman1's Inception git repository: https://github.com/Forstman1/inception-42
- AI usage: used to polish scripts, review subject requirements, refine documentation and Makefile (add emojis), CSS files, and for my many many questions.
