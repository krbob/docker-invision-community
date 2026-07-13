#!/bin/sh
set -eu

# shellcheck disable=SC1091
. /usr/local/bin/restic-credentials.sh

restic forget --retry-lock 5m --tag invision --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
