#!/bin/bash
set -euo pipefail

if [ -z "${MARIADB_ROOT_PASSWORD:-}" ]; then
    echo "Missing MARIADB_ROOT_PASSWORD." >&2
    exit 1
fi

if [ ! -f /var/backup/ips.sql ]; then
    echo "Missing backup file /var/backup/ips.sql." >&2
    exit 1
fi

mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" < /var/backup/ips.sql
