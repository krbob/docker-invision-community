FROM alpine:3.24

RUN apk add --no-cache logrotate tzdata

COPY logrotate.conf /etc/

RUN chmod 644 /etc/logrotate.conf

CMD ["logrotate", "-s", "/var/log/.logrotate.status", "/etc/logrotate.conf"]
