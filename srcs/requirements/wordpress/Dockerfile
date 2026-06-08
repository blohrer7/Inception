# Basis-Image: debian:bookworm – kein nginx hier, nur PHP-FPM!
FROM debian:bookworm

# PHP 8.2 (bookworm-Standard), mysql-Extension für WP, mariadb-client für health-check
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    wget \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# WP-CLI: Kommandozeilen-Tool für WordPress (Installation, User-Anlage, etc.)
# Wird aus dem offiziellen Build-Repo geholt, kein DockerHub-Image
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Pool-Konfiguration: PHP-FPM auf TCP-Port 9000 statt Unix-Socket
# (Unix-Socket würde nur funktionieren wenn NGINX im gleichen Container wäre)
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Setup-Skript: wartet auf MariaDB, installiert WP, startet PHP-FPM
COPY tools/wp-setup.sh /wp-setup.sh
RUN chmod +x /wp-setup.sh

# WordPress-Verzeichnis vorab anlegen (wird via Volume befüllt)
RUN mkdir -p /var/www/wordpress

# FastCGI-Port – nur intern erreichbar, nicht nach außen exponiert
EXPOSE 9000

ENTRYPOINT ["/wp-setup.sh"]
