#!/bin/sh
set -eu

case "${1:-}" in
certonly)
    if [ -z "${DOMAIN_NAME:-}" ]; then
        echo "Missing DOMAIN_NAME." >&2
        exit 1
    fi

    mkdir -p /var/www/certbot/.well-known/acme-challenge
    certbot certonly -v --webroot -w /var/www/certbot -d "$DOMAIN_NAME" -d "www.${DOMAIN_NAME}" -m "admin@${DOMAIN_NAME}" --agree-tos --no-eff-email --non-interactive --keep-until-expiring 2>&1
    ;;
renew)
    if [ -z "${DOMAIN_NAME:-}" ]; then
        echo "Missing DOMAIN_NAME." >&2
        exit 1
    fi

    mkdir -p /var/www/certbot/.well-known/acme-challenge
    certbot renew --webroot -w /var/www/certbot --non-interactive 2>&1
    ;;
*)
    echo "Usage: $0 {certonly|renew}" >&2
    exit 1
    ;;
esac
