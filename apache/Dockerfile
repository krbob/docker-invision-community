FROM httpd:2.4-bookworm

ENV WWW_DIRECTORY /var/www/ips

ENV CERTBOT_WWW_DIRECTORY /var/www/certbot

ENV CERTIFICATES_DIRECTORY /etc/letsencrypt

COPY httpd-vhosts.conf ${HTTPD_PREFIX}/conf/extra/

COPY generate-self-signed-certs.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/generate-self-signed-certs.sh

RUN /usr/local/bin/generate-self-signed-certs.sh

RUN sed -i \
	-e 's/^#\(Include .*httpd-vhosts.conf\)/\1/' \
	-e 's/^#\(LoadModule .*mod_proxy.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_proxy_fcgi.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_rewrite.so\)/\1/' \
	-e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
	-e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_remoteip.so\)/\1/' \
	-e 's/^#ServerName .*/ServerName ${DOMAIN_NAME}/' \
	${HTTPD_PREFIX}/conf/httpd.conf

RUN sed -i '/<VirtualHost/,/<\/VirtualHost>/ s/^/#/' ${HTTPD_PREFIX}/conf/extra/httpd-ssl.conf