#!/bin/bash
set -e

FTP_PASSWORD=$(cat /run/secrets/db_password)

useradd -m -d /var/www/wordpress ftpuser 2>/dev/null || true
echo "ftpuser:${FTP_PASSWORD}" | chpasswd

exec vsftpd /etc/vsftpd.conf
