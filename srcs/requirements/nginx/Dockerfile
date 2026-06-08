# Basis-Image: debian:bookworm – nur nginx + openssl, kein PHP, kein MariaDB
FROM debian:bookworm

# nginx: Webserver / Reverse Proxy
# openssl: für selbstsigniertes TLS-Zertifikat beim ersten Start
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Server-Block für HTTPS (Port 443) mit FastCGI-Proxy zu wordpress:9000
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Skript generiert das SSL-Zertifikat beim ersten Start und startet nginx
COPY tools/generate-cert.sh /generate-cert.sh
RUN chmod +x /generate-cert.sh

# Einziger nach außen exponierter Port – HTTP (80) wird absichtlich nicht geöffnet
EXPOSE 443

# exec-Form → generate-cert.sh (und danach nginx) werden PID 1
ENTRYPOINT ["/generate-cert.sh"]
