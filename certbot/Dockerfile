# renovate: datasource=docker depName=certbot/certbot
FROM certbot/certbot:v5.6.0@sha256:0107d084c225631fc64a8313e19adb07275f7296fde338f7dfa93986c80b2e3e

COPY certbot.sh /usr/local/bin/certbot.sh

RUN chmod +x /usr/local/bin/certbot.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]
