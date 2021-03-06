FROM php:7.4-apache-buster

ENV ADMIN_EMAIL webmaster@localhost
ENV PHP_TIME_ZONE Europe/London
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_POST_MAX_SIZE 32M

ADD 000-default.conf $APACHE_CONFDIR/sites-available/000-default.conf
ADD php-override.ini $PHP_INI_DIR/conf.d/php-override.ini

RUN apt-get update
RUN apt-get install -y -f apt-transport-https \
		libicu-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libonig-dev \
		libpng-dev \
		libpq-dev \
		libzip-dev \
		acl \
		cron \
		git \
		zip

RUN  docker-php-ext-configure gd --with-jpeg --with-freetype \
	&& docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
	&& docker-php-ext-install \
		bcmath \
		exif \
		gd \
		gettext \
		intl \
		mbstring \
		mysqli \
		opcache \
		pgsql \
		pdo \
		pdo_mysql \
		pdo_pgsql \
		zip

RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer self-update --1

RUN a2enmod rewrite \
	&& a2enmod http2 \
	&& mkdir -p /etc/cron.d/ \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& service cron start \
	&& ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log
