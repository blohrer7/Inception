FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/99-inception.cnf

COPY tools/init-db.sh /init-db.sh
RUN chmod +x /init-db.sh

EXPOSE 3306

ENTRYPOINT ["/init-db.sh"]
