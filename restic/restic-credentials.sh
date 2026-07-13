#!/bin/sh
set -eu

if [ -z "${RESTIC_REPOSITORY:-}" ] || [ ! -r "${RESTIC_PASSWORD_FILE:-}" ]; then
  echo "Missing RESTIC_REPOSITORY or readable RESTIC_PASSWORD_FILE." >&2
  exit 1
fi

if [ ! -r "${AWS_CREDENTIALS_FILE:-}" ]; then
  echo "Missing readable AWS_CREDENTIALS_FILE." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$AWS_CREDENTIALS_FILE"
set +a

if [ -z "${AWS_ACCESS_KEY_ID:-}" ] || [ -z "${AWS_SECRET_ACCESS_KEY:-}" ]; then
  echo "AWS credentials file must define AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY." >&2
  exit 1
fi
