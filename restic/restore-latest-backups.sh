#!/bin/sh
set -eu

restic restore latest --retry-lock 5m --target / \
  --include /var/backup/db/ips.sql \
  --include /var/backup/www/ips.tar
