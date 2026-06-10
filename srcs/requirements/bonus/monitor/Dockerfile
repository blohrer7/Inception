FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    python3 \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

COPY tools/start.sh /start.sh
COPY conf/server.py /server.py
RUN chmod +x /start.sh

EXPOSE 9000

ENTRYPOINT ["/start.sh"]
