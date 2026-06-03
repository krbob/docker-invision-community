#!/bin/bash
set -euo pipefail

mkdir -p /var/log/redis

chown -R redis:redis /var/log/redis

exec docker-entrypoint.sh "$@"
