FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    python3 \
    && rm -rf /var/lib/apt/lists/*

COPY tools/start.sh /start.sh
COPY conf/index.html /index.html
RUN chmod +x /start.sh

EXPOSE 9000

ENTRYPOINT ["/start.sh"]
