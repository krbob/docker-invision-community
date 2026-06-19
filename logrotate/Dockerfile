FROM alpine:3.24

RUN apk add --no-cache logrotate tzdata

COPY logrotate.conf /etc/

CMD ["logrotate", "-s", "/var/log/.logrotate.status", "/etc/logrotate.conf"]
