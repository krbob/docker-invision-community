#!/bin/bash

mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" < /var/backup/ips.sql