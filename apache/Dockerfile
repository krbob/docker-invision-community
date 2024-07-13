FROM httpd:2.4-bookworm

COPY httpd-vhosts.conf ${HTTPD_PREFIX}/conf/extra/

RUN sed -i \
	-e 's/^#\(Include .*httpd-vhosts.conf\)/\1/' \
	-e 's/^#\(LoadModule .*mod_proxy.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_proxy_fcgi.so\)/\1/' \
	-e 's/^#\(LoadModule .*mod_rewrite.so\)/\1/' \
	-e 's/^#ServerName .*/ServerName ${DOMAIN_NAME}/' \
	${HTTPD_PREFIX}/conf/httpd.conf