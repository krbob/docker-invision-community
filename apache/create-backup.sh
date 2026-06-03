#!/bin/bash
set -euo pipefail

mkdir -p /var/backup
rm -f /var/backup/ips.tar.gz

tar -cpzf /var/backup/ips.tar.gz -C /var/www ips
