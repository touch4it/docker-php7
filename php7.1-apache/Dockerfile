FROM php:7.1-apache

ENV ADMIN_EMAIL webmaster@localhost
ENV PHP_TIME_ZONE Europe/London
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_POST_MAX_SIZE 32M

ADD 000-default.conf $APACHE_CONFDIR/sites-available/000-default.conf
ADD php-override.ini $PHP_INI_DIR/conf.d/php-override.ini

RUN apt-get update \
	&& apt-get install -y \
		libicu-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng12-dev \
		libpq-dev \
		libzip-dev \
		acl \
		cron \
		git \
		zip \
	&& curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-freetype-dir=/usr/include/ \
	&& docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
	&& docker-php-ext-configure zip \
		--with-libzip \
	&& docker-php-ext-install \
		exif \
		gd \
		intl \
		mbstring \
		mysqli \
		opcache \
		pgsql \
		pdo \
		pdo_mysql \
		pdo_pgsql \
		zip \
	&& a2enmod rewrite \
	&& mkdir -p /etc/cron.d/ \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& service cron start \
	&& ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log
