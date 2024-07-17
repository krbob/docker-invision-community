FROM php:8.1-fpm-bookworm

ENV WWW_DIRECTORY /var/www/ips

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN install-php-extensions gd zip exif gmp mysqli

RUN	cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\(;*disable_functions\s*=\s*\).*$/disable_functions=exec,system,passthru,popen,proc_open,shell_exec/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's|^\(error_log\s*=\s*\).*|\1log/error.log|' "$PHP_INI_DIR/../php-fpm.d/docker.conf"

COPY ips_task.sh /usr/local/bin/