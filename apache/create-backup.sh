#!/bin/bash
set -euo pipefail

mkdir -p /var/backup

trap 'rm -f /var/backup/ips.tar.gz.tmp' EXIT

tar -cpzf /var/backup/ips.tar.gz.tmp -C /var/www ips

mv /var/backup/ips.tar.gz.tmp /var/backup/ips.tar.gz
