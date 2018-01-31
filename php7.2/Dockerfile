FROM php:7.2-apache

ENV APACHE_ADMIN_EMAIL webmaster@localhost
ENV PHP_TIME_ZONE Europe/London
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_POST_MAX_SIZE 32M

ADD 000-default.conf $APACHE_CONFDIR/sites-available/000-default.conf
ADD symfony.ini $PHP_INI_DIR/conf.d/symfony.ini

RUN apt-get update \
	&& apt-get install -y -f apt-transport-https \
		libicu-dev \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
		libpq-dev \
		acl \
		cron \
		git \
		zip \
	&& curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-freetype-dir=/usr/include/ \
	&& docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
	&& docker-php-ext-install \
		exif \
		gd \
		intl \
		mbstring \
		opcache \
		pgsql \
		pdo \
		pdo_mysql \
		pdo_pgsql \
		zip \
	&& a2enmod rewrite \
	&& mkdir -p /var/www/html/web \
	&& mkdir -p /var/www/html/web/uploads \
	&& setfacl -R -m u:"$APACHE_RUN_USER":rwX web/uploads \
	&& setfacl -dR -m u:"$APACHE_RUN_USER":rwX web/uploads \
	&& mkdir -p /var/www/html/web/media \
	&& setfacl -R -m u:"$APACHE_RUN_USER":rwX web/media \
	&& setfacl -dR -m u:"$APACHE_RUN_USER":rwX web/media \
	&& mkdir -p /var/www/html/var \
	&& setfacl -R -m u:"$APACHE_RUN_USER":rwX var \
	&& setfacl -dR -m u:"$APACHE_RUN_USER":rwX var \
	&& mkdir -p /etc/cron.d/ \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& service cron start
