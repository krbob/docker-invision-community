FROM redis:6.2-bookworm

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["redis-server", "--maxmemory 256mb", "--maxmemory-policy allkeys-lru"]