# Basis-Image: debian:bookworm (penultimate stable – Alpine wäre die Alternative)
# "latest" ist laut Subject verboten, daher expliziter Tag
FROM debian:bookworm

# Nur mariadb-server – kein nginx, kein PHP, kein unnötiger Ballast
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*   # Layer klein halten

# Eigene MariaDB-Konfiguration (bind-address auf 0.0.0.0, damit andere Container zugreifen können)
COPY conf/my.cnf /etc/mysql/conf.d/inception.cnf

# Initialisierungs-Skript: erstellt DB + User beim ersten Start
COPY tools/init-db.sh /init-db.sh
RUN chmod +x /init-db.sh

# Port nur im internen Docker-Netzwerk erreichbar – nicht nach außen exponiert
EXPOSE 3306

# exec-Form → init-db.sh wird PID 1 (korrekte Signal-Weiterleitung, kein Shell-Wrapper)
ENTRYPOINT ["/init-db.sh"]
