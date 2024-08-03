#!/bin/bash

rm -f /var/backup/ips.tar.gz

tar -cpzf /var/backup/ips.tar.gz -C /var/www ips