#!/bin/sh
set -eu

# shellcheck disable=SC1091
. /usr/local/bin/restic-credentials.sh

if [ ! -f /var/backup/db/ips.sql ] || [ ! -f /var/backup/www/ips.tar ]; then
  echo "Missing backup files."
  exit 1
fi

restic backup --retry-lock 5m --tag invision /var/backup/db/ips.sql /var/backup/www/ips.tar
