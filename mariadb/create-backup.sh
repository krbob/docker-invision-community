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

if [ -z "${MARIADB_DATABASE:-}" ]; then
    echo "Missing MARIADB_DATABASE." >&2
    exit 1
fi

mkdir -p /var/backup

trap 'rm -f /var/backup/ips.sql.tmp' EXIT

MYSQL_PWD="$MARIADB_ROOT_PASSWORD" mariadb-dump \
    --databases "$MARIADB_DATABASE" \
    --add-drop-database \
    --events \
    --routines \
    --single-transaction \
    --quick \
    --triggers \
    -uroot > /var/backup/ips.sql.tmp

mv /var/backup/ips.sql.tmp /var/backup/ips.sql
