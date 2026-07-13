# renovate: datasource=docker depName=library/redis
FROM redis:6.2@sha256:da7091440b2b4d9456603be812dba895cd75bedd66564d7f01f1f010521f8467

COPY ips-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/ips-entrypoint.sh

ENTRYPOINT ["ips-entrypoint.sh"]

CMD ["redis-server", "--maxmemory", "128mb", "--maxmemory-policy", "allkeys-lru", "--logfile", "/var/log/redis/redis.log", "--loglevel", "warning"]
