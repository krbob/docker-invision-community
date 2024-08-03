#!/bin/sh

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$RESTIC_REPOSITORY" ] || [ -z "$RESTIC_PASSWORD" ]; then
  echo "Missing required environment variables."
  exit 1
fi

restic backup /var/backup/db/ips.sql /var/backup/www/ips.tar.gz