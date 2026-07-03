#!/bin/bash
set -euo pipefail

if [ ! -f /var/backup/ips.tar ]; then
    echo "Missing backup file /var/backup/ips.tar." >&2
    exit 1
fi

tar -tf /var/backup/ips.tar > /dev/null

find /var/www/ips -mindepth 1 -delete

tar -xpf /var/backup/ips.tar -C /var/www
