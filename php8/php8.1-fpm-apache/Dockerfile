FROM  php:8.1.16-fpm-bullseye

LABEL maintainer="Touch4IT <admin@touch4it.com>"

ENV ADMIN_EMAIL webmaster@localhost

ENV PHP_TIME_ZONE UTC
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_POST_MAX_SIZE 32M

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
		acl \
		bash \
		cron \
		curl \
		gettext \
		git \
		libicu-dev \
		libjpeg-dev \
		libfreetype6-dev \
		libmagickwand-dev \
		libonig-dev \
		libpng-dev \
		libpq-dev \
		libwebp-dev \
		libxml2-dev \
		libzip-dev \
		zip \
		zlib1g-dev \
		grep \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

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
RUN pecl install imagick \
	&& docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	&& docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
	&& docker-php-ext-configure bcmath --enable-bcmath \
	&& docker-php-ext-install \
		bcmath \
		exif \
		gd \
		gettext \
		intl \
		mysqli \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		pgsql \
		zip \
	&& docker-php-ext-enable \
		imagick

#
# APACHE
#

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends apache2; \
	apt-get clean; \
	rm -rf /var/lib/apt/lists/*; \
	\
# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
	sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS"; \
	\
# setup directories and permissions
	. "$APACHE_ENVVARS"; \
	for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
	; do \
		rm -rvf "$dir"; \
		mkdir -p "$dir"; \
		chown "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
		chmod 777 "$dir"; \
	done; \
	\
# delete the "index.html" that installing Apache drops in here
	rm -rvf /var/www/html/*; \
	\
# logs should go to stdout / stderr
	ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log"; \
	ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log"; \
	ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"; \
	chown -R --no-dereference "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$APACHE_LOG_DIR"

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event \
	&& a2enmod mpm_prefork

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
		echo '<FilesMatch \.php$>'; \
		echo '\tSetHandler application/x-httpd-php'; \
		echo '</FilesMatch>'; \
		echo; \
		echo 'DirectoryIndex disabled'; \
		echo 'DirectoryIndex index.php index.html'; \
		echo; \
		echo '<Directory /var/www/>'; \
		echo '\tOptions -Indexes'; \
		echo '\tAllowOverride All'; \
		echo '</Directory>'; \
	} | tee "$APACHE_CONFDIR/conf-available/docker-php.conf" \
	&& a2enconf docker-php

RUN a2enmod \
	http2 \
	proxy_fcgi \
	rewrite \
	setenvif

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGQUIT

# Add configuration
COPY ./docker-vars.ini /usr/local/etc/php/conf.d/docker-vars.ini
COPY ./www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./000-default.conf $APACHE_CONFDIR/sites-available/000-default.conf

EXPOSE 80

COPY ./apache2-foreground /usr/local/bin/
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/apache2-foreground
CMD ["/entrypoint.sh"]
