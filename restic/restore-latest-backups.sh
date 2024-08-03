#!/bin/sh

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$RESTIC_REPOSITORY" ] || [ -z "$RESTIC_PASSWORD" ]; then
  echo "Missing required environment variables."
  exit 1
fi

restic restore latest --target / --include /var/backup/db/ips.sql
restic restore latest --target / --include /var/backup/www/ips.tar.gz