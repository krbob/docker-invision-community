#!/bin/bash
set -euo pipefail

mkdir -p /var/log/mysql

chown -R mysql:mysql /var/log/mysql

exec docker-entrypoint.sh "$@"
