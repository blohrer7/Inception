FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    redis \
    && rm -rf /var/lib/apt/lists/*

COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6379

ENTRYPOINT ["/start.sh"]
