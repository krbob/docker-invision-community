FROM php:8.1-fpm-bookworm

RUN TEMP_PACKAGES=" \
	# GD:
	libfreetype6-dev \
	libjpeg62-turbo-dev \
	libpng-dev \
	libxpm-dev \
	libwebp-dev \
	libavif-dev \
	libaom-dev \
	libdav1d-dev \
	# ZIP:
	cmake \
	gnutls-dev \
	libzip-dev \
	libbz2-dev \
	zlib1g-dev \
	# SSL:
	^libssl([0-9]+(\.[0-9]+)*)?-dev$ \
	" && apt-get update && apt-get install -y --no-install-recommends ${TEMP_PACKAGES} \
	# GD:
	libfreetype6 \
	libjpeg62-turbo \
	^libpng[0-9]+-[0-9]+$ \
	libxpm4 \
	^libwebp[0-9]+$ \
	^libavif[0-9]+$ \
	^libaom[0-9]+$ \
	^libdav1d[0-9]+$ \
	# ZIP:
	^libzip[0-9]$ \
	# GMP:
	libgmp-dev \
	&& docker-php-ext-configure gd --enable-gd --with-webp --with-jpeg --with-xpm --with-freetype --with-avif \
	&& docker-php-ext-configure zip \
	&& docker-php-ext-configure exif \
	&& docker-php-ext-configure gmp \
	&& docker-php-ext-configure mysqli \
	&& docker-php-ext-install -j$(nproc) gd zip exif gmp mysqli \
	&& apt-get remove --purge -y ${TEMP_PACKAGES} \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

RUN	cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/conf.d/php.ini" \
	&& sed -i 's/^\(;*disable_functions\s*=\s*\).*$/disable_functions=exec,system,passthru,popen,proc_open,shell_exec/' "$PHP_INI_DIR/conf.d/php.ini"