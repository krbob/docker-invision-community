FROM mariadb:10.11-jammy

RUN mkdir -p /var/log/mysql && chmod 777 /var/log/mysql

RUN sed -i \
    -e 's|^\(#*\)\(log_error\s*=\s*\).*|\2/var/log/mysql/error.log|' \
    -e 's|^\(#*\)\(innodb_buffer_pool_size\s*=\s*\).*|\2 512M|' \
    /etc/mysql/mariadb.conf.d/50-server.cnf