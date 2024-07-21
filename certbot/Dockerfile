FROM certbot/certbot:v2.11.0

COPY certbot.sh /usr/local/bin/certbot.sh

RUN chmod +x /usr/local/bin/certbot.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]