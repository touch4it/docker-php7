FROM php:8.0-apache-buster

ENV ADMIN_EMAIL webmaster@localhost
ENV PHP_TIME_ZONE Europe/London
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_POST_MAX_SIZE 32M

ADD 000-default.conf $APACHE_CONFDIR/sites-available/000-default.conf
ADD php-override.ini $PHP_INI_DIR/conf.d/php-override.ini

RUN apt update
RUN apt install -y --no-install-recommends \
		acl \
		bash \
		cron \
		gettext \
		git \
		libicu-dev \
		libjpeg-dev \
		libfreetype6-dev \
		libonig-dev \
		libpng-dev \
		libpq-dev \
		libxml2-dev \
		libzip-dev \
		zip \
		grep

#
# CRON
#

RUN mkdir -m 0644 -p /etc/cron.d \
	&& mkdir -m 0644 -p /var/log/cron \
	&& touch /var/log/cron/cron.log

#
# COMPOSER
#

RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer self-update

#
# PHP extensions
#

RUN docker-php-ext-configure gd --with-jpeg --with-freetype
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
RUN docker-php-ext-install bcmath \
	exif \
	gd \
	gettext \
	intl \
	mysqli \
	opcache \
	pdo_mysql \
	pdo_pgsql \
	pgsql \
	zip
RUN docker-php-ext-configure bcmath --enable-bcmath

#
# Apache
#

RUN a2enmod rewrite \
	&& a2enmod http2 \
	# && apt-get clean \
	# && rm -rf /var/lib/apt/lists/* \
	&& ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log
