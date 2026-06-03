#!/bin/bash
set -euo pipefail

if [ ! -f /var/backup/ips.tar.gz ]; then
    echo "Missing backup file /var/backup/ips.tar.gz." >&2
    exit 1
fi

tar -xpzf /var/backup/ips.tar.gz -C /var/www
