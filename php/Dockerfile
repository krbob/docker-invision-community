FROM php:8.1-fpm-bookworm

ENV WWW_DIRECTORY=/var/www/ips

RUN apt-get update && apt-get install -y locales

COPY locale.gen /etc/

RUN dpkg-reconfigure --frontend=noninteractive locales

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions gd imagick zip exif gmp mysqli redis

RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\(;*disable_functions\s*=\s*\).*$/disable_functions=exec,system,passthru,popen,proc_open,shell_exec/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^memory_limit = .*/memory_limit = 256M/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 32M/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^post_max_size = .*/post_max_size = 64M/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\s*;\s*opcache.enable\s*=.*/opcache.enable=1/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\s*;\s*opcache.memory_consumption\s*=.*/opcache.memory_consumption=128/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\s*;\s*opcache.interned_strings_buffer\s*=.*/opcache.interned_strings_buffer=8/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\s*;\s*opcache.max_accelerated_files\s*=.*/opcache.max_accelerated_files=4000/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\s*;\s*opcache.revalidate_freq\s*=.*/opcache.revalidate_freq=60/' "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's|^\(error_log\s*=\s*\).*|\1log/error.log|' "$PHP_INI_DIR/../php-fpm.d/docker.conf" \
	&& sed -i 's/^pm.max_children = .*/pm.max_children = 10/' "$PHP_INI_DIR/../php-fpm.d/www.conf"

COPY ips-task.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/ips-task.sh