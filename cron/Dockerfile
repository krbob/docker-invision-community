# renovate: datasource=docker depName=library/alpine
FROM alpine:3.24@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

RUN apk add --no-cache docker-cli tzdata

COPY run-with-logging.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/run-with-logging.sh

COPY crontab /etc/crontabs/root

CMD ["crond", "-f"]
