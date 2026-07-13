#!/bin/sh
set -eu

TRUSTED_PROXIES_FILE="${HTTPD_PREFIX}/conf/extra/trusted-proxies.conf"

: > "$TRUSTED_PROXIES_FILE"

if [ -n "${TRUSTED_PROXY_CIDRS:-}" ]; then
    {
        printf '%s\n' 'RemoteIPHeader CF-Connecting-IP'

        set -f
        for proxy in $(printf '%s' "$TRUSTED_PROXY_CIDRS" | tr ', ' '\n'); do
            case "$proxy" in
                *[!0-9A-Fa-f:./]*)
                    echo "Invalid trusted proxy CIDR: $proxy" >&2
                    exit 1
                    ;;
            esac

            printf 'RemoteIPTrustedProxy %s\n' "$proxy"
        done
    } > "$TRUSTED_PROXIES_FILE"
fi

exec "$@"
