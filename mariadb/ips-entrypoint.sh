#!/bin/bash

mkdir -p /var/log/mysql

chown -R mysql:mysql /var/log/mysql

exec docker-entrypoint.sh "$@"