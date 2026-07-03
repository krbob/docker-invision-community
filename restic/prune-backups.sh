#!/bin/sh
set -eu

if [ -z "${AWS_ACCESS_KEY_ID:-}" ] || [ -z "${AWS_SECRET_ACCESS_KEY:-}" ] || [ -z "${RESTIC_REPOSITORY:-}" ] || [ -z "${RESTIC_PASSWORD:-}" ]; then
  echo "Missing required environment variables."
  exit 1
fi

restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
