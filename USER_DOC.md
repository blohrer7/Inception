# User Documentation — Inception

This document explains how to use and manage the Inception stack as an end user or administrator. No Docker knowledge required.

---

## What this stack provides

The infrastructure runs several services, each in its own container:

| Service | What it does | Address |
|---|---|---|
| WordPress | The main website and CMS | https://blohrer.42.fr |
| NGINX | Handles all incoming HTTPS traffic | https://blohrer.42.fr (port 443) |
| MariaDB | Database storing all WordPress content | internal only |
| Redis | Speeds up WordPress by caching database queries | internal only |
| Adminer | Web interface for browsing the database | http://blohrer.42.fr:8080 |
| Static site | Simple HTML page | http://blohrer.42.fr:80 |
| FTP server | Upload files directly to the WordPress volume | blohrer.42.fr port 21 |
| Docker Monitor | Displays the status of all running containers | http://blohrer.42.fr:9000 |

---

## Starting and stopping the project

**Start everything:**
```bash
make
```

**Stop all containers (data is preserved):**
```bash
make down
```

**Full restart:**
```bash
make re
```

---

## Accessing the website

Open your browser and go to:

```
https://blohrer.42.fr
```

A security warning will appear because the SSL certificate is self-signed. Click "Advanced" and then "Proceed" to continue — this is expected behavior.

---

## Accessing the WordPress admin panel

Go to:

```
https://blohrer.42.fr/wp-admin
```

Log in with the administrator account. The admin username is `blohrer`. The password is stored in `secrets/credentials.txt` under `ADMIN_PASSWORD`.

A second user with the role "editor" also exists — username `editor`, password under `USER_PASSWORD` in the same file.

---

## Managing credentials

All passwords are stored in the `secrets/` directory at the root of the repository:

| File | Contains |
|---|---|
| `secrets/db_password.txt` | WordPress database user password |
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/credentials.txt` | WordPress admin and editor passwords |

These files are excluded from Git and must be created manually during setup. Never commit them.

---

## Checking that services are running

Run the following command to see the status of all containers:

```bash
sudo docker ps
```

Every container should show `Up` in the STATUS column. If any container shows `Restarting` or `Exited`, something went wrong — check the logs:

```bash
make logs
```

---

## Accessing the database via Adminer

Open:

```
http://blohrer.42.fr:8080
```

Use the following credentials:

- **System:** MySQL
- **Server:** mariadb
- **Username:** wpuser
- **Password:** content of `secrets/db_password.txt`
- **Database:** wordpress
