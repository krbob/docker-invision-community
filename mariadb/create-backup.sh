#!/bin/bash
set -euo pipefail

if [ -z "${MARIADB_ROOT_PASSWORD:-}" ]; then
    echo "Missing MARIADB_ROOT_PASSWORD." >&2
    exit 1
fi

mkdir -p /var/backup

trap 'rm -f /var/backup/ips.sql.tmp' EXIT

mariadb-dump --all-databases --single-transaction --quick -uroot -p"$MARIADB_ROOT_PASSWORD" > /var/backup/ips.sql.tmp

mv /var/backup/ips.sql.tmp /var/backup/ips.sql
