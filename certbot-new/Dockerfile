FROM certbot/certbot:v2.11.0

ENTRYPOINT ["sh", "-c", "certbot certonly -v --webroot -w /var/www/certbot -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME} -m admin@${DOMAIN_NAME} --agree-tos --keep-until-expiring"]
