FROM mariadb:10.11-jammy

RUN sed -i 's|^\(#*\)\(log_error\s*=\s*\).*|\2/var/log/mysql/error.log|' /etc/mysql/mariadb.conf.d/50-server.cnf