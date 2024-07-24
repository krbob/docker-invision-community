FROM redis:6.2-bookworm

COPY ips-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/ips-entrypoint.sh

ENTRYPOINT ["ips-entrypoint.sh"]

CMD ["redis-server", "--maxmemory", "128mb", "--maxmemory-policy", "allkeys-lru", "--logfile", "/var/log/redis/redis.log"]