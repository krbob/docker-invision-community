#!/bin/bash

rm -f /var/backup/ips.sql

mariadb-dump --all-databases -uroot -p"$MARIADB_ROOT_PASSWORD" > /var/backup/ips.sql