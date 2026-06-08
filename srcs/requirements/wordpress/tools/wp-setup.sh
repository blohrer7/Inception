#!/bin/bash
set -e

# ── Secrets einlesen ──────────────────────────────────────────────────────────
# Passwörter kommen aus Docker Secrets (Dateien unter /run/secrets/),
# niemals aus Umgebungsvariablen oder dem Dockerfile
DB_PASSWORD=$(cat /run/secrets/db_password)
ADMIN_PASSWORD=$(grep 'ADMIN_PASSWORD' /run/secrets/credentials | cut -d= -f2)
USER_PASSWORD=$(grep 'USER_PASSWORD'  /run/secrets/credentials | cut -d= -f2)

WP_PATH=/var/www/wordpress

# ── Warten auf MariaDB ────────────────────────────────────────────────────────
# depends_on in docker-compose garantiert nur dass der Container *gestartet* ist,
# nicht dass MariaDB schon bereit Verbindungen annimmt → aktiv pollen
echo "[wp-setup] Waiting for MariaDB..."
until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    sleep 2
done
echo "[wp-setup] MariaDB is up."

cd "${WP_PATH}"

# ── WordPress Core herunterladen ──────────────────────────────────────────────
# Nur beim ersten Start nötig; wp-login.php als Indikator ob WP bereits vorhanden
if [ ! -f wp-login.php ]; then
    wp core download --allow-root --locale=en_US
fi

# ── wp-config.php anlegen ─────────────────────────────────────────────────────
# Verbindet WP mit der MariaDB; "mariadb" ist der Service-Name aus docker-compose
# (Docker-internes DNS löst den Namen auf die Container-IP auf)
if [ ! -f wp-config.php ]; then
    wp config create \
        --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb \
        --path="${WP_PATH}"
fi

# ── WordPress installieren ────────────────────────────────────────────────────
# Legt Tabellen in der DB an und erstellt die beiden Pflicht-User
if ! wp core is-installed --allow-root 2>/dev/null; then

    # Admin-User: Benutzername darf laut Subject KEIN "admin"/"administrator" enthalten
    wp core install \
        --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email   # keine Bestätigungs-Mail (kein Mailserver vorhanden)

    # Zweiter User mit eingeschränkter Editor-Rolle (kein Admin-Zugang)
    wp user create \
        --allow-root \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${USER_PASSWORD}" \
        --role=editor

    echo "[wp-setup] WordPress installed successfully."
fi

# ── PHP-FPM starten ───────────────────────────────────────────────────────────
# --nodaemonize → Prozess bleibt im Vordergrund = PID 1, kein "tail -f"-Hack nötig
exec /usr/sbin/php-fpm8.2 --nodaemonize
