#!/bin/sh
set -eu

# shellcheck disable=SC1091
. /usr/local/bin/restic-credentials.sh

restic restore latest --retry-lock 5m --target / \
  --include /var/backup/db/ips.sql \
  --include /var/backup/www/ips.tar
