#!/bin/sh

PREFIX=$1
COMMAND=$2

$COMMAND 2>&1 | awk -v prefix="$PREFIX" '{ print strftime("%Y-%m-%d %H:%M:%S"), "- [" prefix "]", $0; }' >> /var/log/cron.log
