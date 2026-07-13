# renovate: datasource=docker depName=library/mariadb
FROM mariadb:10@sha256:be981e4113326ada8d6004174dd09eeaefc03094037f811182a52d4f2e737350

COPY ips-entrypoint.sh create-backup.sh restore-backup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/ips-entrypoint.sh \
    && chmod +x /usr/local/bin/create-backup.sh \
    && chmod +x /usr/local/bin/restore-backup.sh

RUN sed -i \
    -e 's|^\(#*\)\(log_error\s*=\s*\).*|\2/var/log/mysql/error.log|' \
    -e 's|^\(#*\)\(innodb_buffer_pool_size\s*=\s*\).*|\2 512M|' \
    /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT ["ips-entrypoint.sh"]

CMD ["mariadbd"]
