FROM alpine:3.23

RUN apk add --no-cache docker-cli tzdata

COPY run-with-logging.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/run-with-logging.sh

COPY crontab /etc/crontabs/root

CMD ["crond", "-f"]
