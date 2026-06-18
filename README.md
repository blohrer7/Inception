*This project has been created as part of the 42 curriculum by blohrer.*

# Inception

## Description

Inception is a 42 School system administration project. The goal is to build a small but complete web infrastructure entirely from scratch using Docker and Docker Compose, running inside a Debian 12 virtual machine.

Every service runs in its own container, built from a custom Dockerfile based on `debian:bookworm`. No pre-built images from Docker Hub are used — everything is installed and configured manually.

The mandatory stack consists of NGINX as the only entry point (HTTPS, port 443), WordPress with PHP-FPM as the application layer, and MariaDB as the database. On top of that, five bonus services were implemented: a Redis object cache for WordPress, an FTP server pointed at the WordPress volume, a static HTML website, Adminer for database management, and a custom Docker Monitor built in Python.

All sensitive data (passwords, credentials) is handled via Docker secrets. Non-sensitive configuration lives in a `.env` file. Data is persisted through bind-mounted volumes under `/home/blohrer/data/` so everything survives container restarts and VM reboots.

### Project sources

The repository is structured as follows:

```
inception/
├── Makefile                        # Top-level build and management commands
├── secrets/                        # Docker secret files (not committed)
└── srcs/
    ├── docker-compose.yml          # Defines all services, networks, and volumes
    ├── .env                        # Non-sensitive configuration variables
    └── requirements/
        ├── nginx/                  # NGINX container (TLS entry point)
        ├── wordpress/              # WordPress + PHP-FPM container
        ├── mariadb/                # MariaDB container
        ├── redis/                  # Redis cache container (bonus)
        ├── ftp/                    # vsftpd FTP server container (bonus)
        ├── adminer/                # Adminer database UI container (bonus)
        ├── static/                 # Static HTML website container (bonus)
        └── monitor/                # Custom Docker monitor container (bonus)
```

Each `requirements/<service>/` directory contains a `Dockerfile` and a `conf/` or `tools/` subdirectory with all configuration files and entrypoint scripts for that service.

### Design choices

**Why Docker?**
A traditional setup would mean installing nginx, PHP, MariaDB and all other services directly on the host machine — mixing their configs, dependencies and processes together. Docker separates each service into its own isolated container with its own filesystem and network interface, while still sharing the host kernel. The result is a reproducible, portable infrastructure that can be torn down and rebuilt with a single command.

### Virtual Machines vs Docker

A VM runs a complete operating system including its own kernel, init system, and drivers. That means gigabytes of disk space and minutes of boot time just to run one service. A Docker container shares the host kernel and only packages what the service actually needs — it starts in seconds and uses a fraction of the resources. The trade-off is isolation: a VM is more strongly isolated since its kernel is completely separate from the host.

### Secrets vs Environment Variables

Environment variables are fine for non-sensitive config like domain names, usernames, or database names — they end up in the image layers and are visible via `docker inspect`. Passwords should never go there. Docker secrets are mounted as files inside the container at `/run/secrets/` at runtime, are never baked into the image, and never appear in `docker inspect` output. This project uses secrets for all passwords and credentials.

### Docker Network vs Host Network

With `network: host`, a container skips Docker's virtual network entirely and binds directly to the host's network interfaces — no isolation, no name resolution between containers, and a direct security risk. A custom bridge network like the `inception` network in this project keeps all containers isolated from the outside world and lets them reach each other by container name (e.g. WordPress connects to `mariadb:3306` without knowing any IP address). Only explicitly mapped ports are reachable from outside.

### Docker Volumes vs Bind Mounts

Docker-managed volumes are handled entirely by Docker and live in `/var/lib/docker/volumes/` — convenient but opaque. Bind mounts map a specific path on the host directly into the container, making it easy to inspect, back up, or debug the data. This project uses bind mounts under `/home/blohrer/data/mariadb` and `/home/blohrer/data/wordpress` so the data is always visible and survives any number of container rebuilds.

---

## Instructions

**Requirements:** Debian-based VM (tested on Debian 12), Docker with Compose V2, Make.

Clone the repository, then run:

```bash
make
```

For full setup instructions (secrets, `.env`, hosts entry, all Makefile commands) see [DEV_DOC.md](DEV_DOC.md).

---

## Resources

### Docker

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker networking overview](https://docs.docker.com/network/)

### Services

- [NGINX documentation](https://nginx.org/en/docs/)
- [NGINX SSL/TLS configuration guide](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress CLI documentation](https://developer.wordpress.org/cli/commands/)
- [Redis documentation](https://redis.io/docs/)
- [vsftpd documentation](https://security.appspot.com/vsftpd.html)
- [Adminer documentation](https://www.adminer.org/)

### Tutorials and articles

- [How HTTPS works](https://howhttps.works/)
- [Understanding PID 1 in Docker containers](https://www.cloudbees.com/blog/java-deep-dive-docker-pid-1)
- [Docker volumes vs bind mounts](https://docs.docker.com/storage/volumes/)
- [WordPress object caching with Redis](https://developer.wordpress.org/reference/classes/wp_object_cache/)

### Use of AI

Claude (Anthropic) was used throughout the project as a learning and debugging tool — not to generate code blindly, but to understand what was being built. Concretely it helped with understanding MariaDB networking and the `bind-address` configuration, debugging vsftpd passive port issues, understanding the difference between exec-form and shell-form ENTRYPOINT, and clarifying Docker concepts like PID 1, secrets, and bridge networks. Every solution was read, understood, and manually applied.
