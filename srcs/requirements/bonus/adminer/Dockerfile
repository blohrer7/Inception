FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-cli \
    php-mysqli \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget -q https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -O /var/www/html/index.php

EXPOSE 8080

COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
