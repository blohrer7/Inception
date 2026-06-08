#!/bin/bash
# Bricht sofort ab wenn ein Befehl fehlschlägt
set -e

# Passwörter aus Docker Secrets lesen (niemals als Umgebungsvariable übergeben!)
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Nur beim allerersten Start: Daten-Verzeichnis initialisieren und Datenbank anlegen.
# Danach liegt /var/lib/mysql/mysql bereits auf dem Volume → Block wird übersprungen.
if [ ! -d /var/lib/mysql/mysql ]; then

    # Leeres MariaDB-Daten-Verzeichnis anlegen (kein Server gestartet)
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # Einmalige Bootstrap-SQL-Befehle direkt an mysqld übergeben (kein laufender Server nötig)
    mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;

-- Root-Passwort setzen (Standard ist leer → Sicherheitslücke)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Anonyme Benutzer entfernen
DELETE FROM mysql.user WHERE User='';

-- Test-Datenbank löschen (wird von mysql_install_db angelegt, nicht gebraucht)
DROP DATABASE IF EXISTS test;

-- WordPress-Datenbank und dedizierten User anlegen
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

-- User hat alle Rechte auf die WordPress-DB, sonst nichts
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF
fi

# exec ersetzt diesen Shell-Prozess → mysqld wird PID 1 (empfängt Signale korrekt)
# tail -f / sleep infinity wären verbotene Hacks laut Subject
exec mysqld --user=mysql
