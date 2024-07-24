#!/bin/bash

mkdir -p /var/log/redis

chown -R redis:redis /var/log/redis

exec docker-entrypoint.sh "$@"