#!/bin/bash
set -e

SSL_DIR=/etc/nginx/ssl

# Verzeichnis für Zertifikate anlegen falls nicht vorhanden
mkdir -p "${SSL_DIR}"

# Zertifikat nur beim ersten Start generieren; bei Neustart des Containers
# ist das SSL_DIR leer (kein persistentes Volume für NGINX) → wird neu erstellt
if [ ! -f "${SSL_DIR}/cert.crt" ]; then
    openssl req -x509 -nodes -newkey rsa:4096 \
        -keyout "${SSL_DIR}/cert.key" \
        -out    "${SSL_DIR}/cert.crt" \
        -days   365 \
        # -nodes: privater Schlüssel ohne Passphrase (nötig damit nginx ohne Prompt startet)
        # rsa:4096: ausreichend starker Schlüssel
        -subj   "/C=DE/ST=Bavaria/L=Munich/O=42/OU=Inception/CN=blohrer.42.fr"
    echo "[nginx] Self-signed certificate generated."
fi

# exec → nginx wird PID 1 (empfängt SIGTERM korrekt beim docker stop)
# "daemon off;" verhindert dass nginx in den Hintergrund geht (wäre wie tail -f)
exec nginx -g 'daemon off;'
