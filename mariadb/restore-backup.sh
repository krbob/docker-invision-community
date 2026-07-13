#!/bin/bash
set -euo pipefail

MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD:-}
if [ -z "$MARIADB_ROOT_PASSWORD" ] && [ -r "${MARIADB_ROOT_PASSWORD_FILE:-}" ]; then
    MARIADB_ROOT_PASSWORD=$(cat "$MARIADB_ROOT_PASSWORD_FILE")
fi

if [ -z "$MARIADB_ROOT_PASSWORD" ]; then
    echo "Missing MARIADB_ROOT_PASSWORD." >&2
    exit 1
fi

if [ ! -f /var/backup/ips.sql ]; then
    echo "Missing backup file /var/backup/ips.sql." >&2
    exit 1
fi

MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb -uroot < /var/backup/ips.sql
