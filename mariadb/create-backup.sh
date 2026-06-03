#!/bin/bash
set -euo pipefail

if [ -z "${MARIADB_ROOT_PASSWORD:-}" ]; then
    echo "Missing MARIADB_ROOT_PASSWORD." >&2
    exit 1
fi

mkdir -p /var/backup
rm -f /var/backup/ips.sql

mariadb-dump --all-databases -uroot -p"$MARIADB_ROOT_PASSWORD" > /var/backup/ips.sql
