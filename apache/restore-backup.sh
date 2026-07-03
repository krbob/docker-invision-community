#!/bin/bash
set -euo pipefail

if [ ! -f /var/backup/ips.tar ]; then
    echo "Missing backup file /var/backup/ips.tar." >&2
    exit 1
fi

tar -xpf /var/backup/ips.tar -C /var/www
