# Developer Documentation — Inception

This document describes how to set up, build, and manage the Inception infrastructure from a developer perspective.

---

## Prerequisites

Before starting, make sure the following are available on your machine:

- Debian-based VM (project was developed and tested on Debian 12 / bookworm)
- Docker Engine with Compose V2 — install via the official Docker repository, not via `apt` alone (the packaged version is often too old)
- Make
- Git

To verify your Docker Compose version:

```bash
docker compose version
# should return Docker Compose version v2.x.x
```

---

## Project structure

```
inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/              ← not in Git, must be created manually
│   ├── db_password.txt
│   ├── db_root_password.txt
│   └── credentials.txt
└── srcs/
    ├── .env              ← not in Git, must be created manually
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        ├── wordpress/
        ├── mariadb/
        └── bonus/
            ├── adminer/
            ├── ftp/
            ├── monitor/
            ├── redis/
            └── static/
```

Each service has its own directory containing a `Dockerfile`, a `conf/` folder for configuration files, and a `tools/` folder for entrypoint scripts.

---

## Configuration files

### secrets/

Create the secrets directory and populate it:

```bash
mkdir -p secrets
echo "your_db_password"   > secrets/db_password.txt
echo "your_root_password" > secrets/db_root_password.txt
printf "ADMIN_PASSWORD=your_admin_pass\nUSER_PASSWORD=your_user_pass\n" > secrets/credentials.txt
```

These files are mounted into the containers at runtime under `/run/secrets/` and are never baked into images.

### srcs/.env

Create the environment file:

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

This file holds non-sensitive configuration. It is excluded from Git.

### /etc/hosts

Add the domain to your local hosts file so the browser resolves it to the VM:

```bash
echo "127.0.0.1 blohrer.42.fr" | sudo tee -a /etc/hosts
```

---

## Building and launching

Everything is managed through the Makefile which wraps `docker compose`:

```bash
make        # creates data directories, builds all images, starts all containers
make down   # stops and removes containers (volumes and data are preserved)
make re     # full restart: down + build + up
make clean  # down + remove all images + delete /home/blohrer/data/
make fclean # clean + prune all unused Docker volumes
make logs   # follow logs of all containers live
make ps     # show status of all containers
```

The first `make` will take a few minutes since all images are built from scratch. Subsequent builds are faster thanks to Docker's layer cache — unless you run `make clean` first.

---

## Container and volume management

### Check running containers

```bash
sudo docker ps
```

### Follow logs of a specific container

```bash
sudo docker logs -f nginx
sudo docker logs -f wordpress
sudo docker logs -f mariadb
```

### Open a shell inside a container

```bash
sudo docker exec -it wordpress bash
sudo docker exec -it mariadb bash
```

### Connect to the database directly

```bash
sudo docker exec -it mariadb mariadb -u wpuser -p wordpress
```

### Check volumes

```bash
sudo docker volume ls
sudo docker volume inspect srcs_mariadb
sudo docker volume inspect srcs_wordpress
```

---

## Data storage and persistence

All persistent data is stored on the VM host using bind mounts:

| Volume | Host path | Mounted at in container |
|---|---|---|
| mariadb | `/home/blohrer/data/mariadb` | `/var/lib/mysql` |
| wordpress | `/home/blohrer/data/wordpress` | `/var/www/wordpress` |

These directories are created automatically by `make` if they do not exist. Because the data lives on the host and not inside the containers, it survives `docker compose down`, image rebuilds, and VM reboots. Running `make clean` deletes these directories and all data inside them — use with caution.

---

## After a VM reboot

Docker does not start automatically after a reboot on the 42 school VMs. After SSHing back in:

```bash
cd ~/inception
sudo make
```

If you get a Docker socket permission error, prefix with `sudo` or add your user to the docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```
