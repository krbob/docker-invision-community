FROM certbot/certbot:v3.3.0

COPY certbot.sh /usr/local/bin/certbot.sh

RUN chmod +x /usr/local/bin/certbot.sh

ENTRYPOINT ["tail", "-f", "/dev/null"]