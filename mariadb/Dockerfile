FROM mariadb:10.11-jammy

COPY ips-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/ips-entrypoint.sh

RUN sed -i \
    -e 's|^\(#*\)\(log_error\s*=\s*\).*|\2/var/log/mysql/error.log|' \
    -e 's|^\(#*\)\(innodb_buffer_pool_size\s*=\s*\).*|\2 512M|' \
    /etc/mysql/mariadb.conf.d/50-server.cnf

ENTRYPOINT ["ips-entrypoint.sh"]

CMD ["mariadbd"]