# renovate: datasource=docker depName=library/alpine
FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

RUN apk add --no-cache logrotate tzdata

COPY logrotate.conf /etc/

RUN chmod 644 /etc/logrotate.conf

CMD ["logrotate", "-s", "/var/log/.logrotate.status", "/etc/logrotate.conf"]
