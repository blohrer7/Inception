FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 21

ENTRYPOINT ["/start.sh"]
