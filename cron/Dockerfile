FROM alpine:3.20.1

RUN apk add --no-cache docker-cli tzdata

COPY crontab /etc/crontabs/root

CMD ["crond", "-f"]