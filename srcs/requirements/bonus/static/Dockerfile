FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

COPY conf/index.html /var/www/html/index.html
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80

ENTRYPOINT ["/start.sh"]
