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
LOCK_NAME=$(printf '%s' "$PREFIX" | tr -cs 'A-Za-z0-9_.-' '_')
LOCK_FILE="/tmp/run-with-logging.${LOCK_NAME}"

trap 'rm -f "$OUTPUT_FILE"' EXIT

log() {
    printf '%s - [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$PREFIX" "$1" >> "$LOG_FILE"
}

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    log 'skipped: previous execution is still running'
    exit 0
fi

if sh -c "$COMMAND" >"$OUTPUT_FILE" 2>&1; then
    STATUS=0
else
    STATUS=$?
fi

while IFS= read -r line || [ -n "$line" ]; do
    log "$line"
done < "$OUTPUT_FILE"

log "exit=$STATUS"
exit "$STATUS"
