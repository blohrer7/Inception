#!/bin/bash
set -e

SSL_DIR=/etc/nginx/ssl

mkdir -p "${SSL_DIR}"

if [ ! -f "${SSL_DIR}/cert.crt" ]; then
    openssl req -x509 -nodes -newkey rsa:4096 \
        -keyout "${SSL_DIR}/cert.key" \
        -out    "${SSL_DIR}/cert.crt" \
        -days   365 \
        -subj   "/C=DE/ST=Bavaria/L=Munich/O=42/OU=Inception/CN=blohrer.42.fr"
    echo "[nginx] Self-signed certificate generated."
fi

exec nginx -g 'daemon off;'
