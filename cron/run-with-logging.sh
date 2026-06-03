#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <prefix> <command>" >&2
    exit 1
fi

PREFIX=$1
COMMAND=$2
LOG_FILE=/var/log/cron.log
OUTPUT_FILE=$(mktemp)

trap 'rm -f "$OUTPUT_FILE"' EXIT

if sh -c "$COMMAND" >"$OUTPUT_FILE" 2>&1; then
    STATUS=0
else
    STATUS=$?
fi

awk -v prefix="$PREFIX" '{ print strftime("%Y-%m-%d %H:%M:%S"), "- [" prefix "]", $0; }' "$OUTPUT_FILE" >> "$LOG_FILE"
exit "$STATUS"
