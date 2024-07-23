FROM php:8.1-fpm-bookworm

ENV WWW_DIRECTORY=/var/www/ips

RUN apt-get update && apt-get install -y locales

COPY locale.gen /etc/

RUN dpkg-reconfigure --frontend=noninteractive locales

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions gd zip exif gmp mysqli redis

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\(;*disable_functions\s*=\s*\).*$/disable_functions=exec,system,passthru,popen,proc_open,shell_exec/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 8M/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's|^\(error_log\s*=\s*\).*|\1log/error.log|' "$PHP_INI_DIR/../php-fpm.d/docker.conf" \
	&& sed -i 's/^pm.max_children = .*/pm.max_children = 10/' "$PHP_INI_DIR/../php-fpm.d/www.conf"

COPY ips-task.sh /usr/local/bin/