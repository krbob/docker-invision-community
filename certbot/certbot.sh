#!/bin/sh

if [ "$1" = "certonly" ]; then
    certbot certonly -v --webroot -w /var/www/certbot -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME} -m admin@${DOMAIN_NAME} --agree-tos --keep-until-expiring 2>&1
elif [ "$1" = "renew" ]; then
    certbot renew --webroot -w /var/www/certbot 2>&1
else
    echo "Usage: $0 {certonly|renew}" >&2
    exit 1
fi
