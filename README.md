*This project has been created as part of the 42 curriculum by blohrer.*

# Inception

## Description

Inception is a 42 School system administration project. The goal is to build a small but complete web infrastructure entirely from scratch using Docker and Docker Compose, running inside a Debian 12 virtual machine.

Every service runs in its own container, built from a custom Dockerfile based on `debian:bookworm`. No pre-built images from Docker Hub are used — everything is installed and configured manually.

The mandatory stack consists of NGINX as the only entry point (HTTPS, port 443), WordPress with PHP-FPM as the application layer, and MariaDB as the database. On top of that, five bonus services were implemented: a Redis object cache for WordPress, an FTP server pointed at the WordPress volume, a static HTML website, Adminer for database management, and a custom Docker Monitor built in Python.

All sensitive data (passwords, credentials) is handled via Docker secrets. Non-sensitive configuration lives in a `.env` file. Data is persisted through bind-mounted volumes under `/home/blohrer/data/` so everything survives container restarts and VM reboots.

---

## Instructions

### Requirements

- Debian-based VM (project was built and tested on Debian 12 / bookworm)
- Docker and Docker Compose V2
- Make

### Setup

Clone the repository and navigate into it:

```bash
git clone https://github.com/blohrer/inception
cd inception
```

Create the secrets directory and populate the secret files:

```bash
mkdir -p secrets
echo "your_db_password"   > secrets/db_password.txt
echo "your_root_password" > secrets/db_root_password.txt
printf "ADMIN_PASSWORD=your_admin_pass\nUSER_PASSWORD=your_user_pass\n" > secrets/credentials.txt
```

Create the `.env` file inside `srcs/`:

```bash
cat > srcs/.env << 'EOF'
DOMAIN_NAME=blohrer.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WP_TITLE=Inception
WP_ADMIN_USER=blohrer
WP_ADMIN_EMAIL=blohrer@student.42.fr
WP_USER=editor
WP_USER_EMAIL=editor@student.42.fr
EOF
```

Add the domain to your local hosts file:

```bash
echo "127.0.0.1 blohrer.42.fr" | sudo tee -a /etc/hosts
```

Build and start everything:

```bash
make
```

### Useful commands

| Command | Effect |
|---|---|
| `make` | Build images and start all containers |
| `make down` | Stop and remove containers (data preserved) |
| `make re` | Full restart (down + up) |
| `make clean` | Remove containers, images, and data directories |
| `make logs` | Follow logs of all containers |
| `make ps` | Show status of all containers |

---

## Project Design

### Why Docker?

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

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Inception guide by imyzf](https://medium.com/@imyzf/inception-3979046d90a0)
- [Inception guide by ssterdev](https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671)

### Use of AI

Claude (Anthropic) was used throughout the project as a learning and debugging tool — not to generate code blindly, but to understand what was being built. Concretely it helped with understanding MariaDB networking and the `bind-address` configuration, debugging vsftpd passive port issues, understanding the difference between exec-form and shell-form ENTRYPOINT, and clarifying Docker concepts like PID 1, secrets, and bridge networks. Every solution was read, understood, and manually applied.
