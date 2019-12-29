FROM php:7.4-fpm-buster

LABEL maintainer="Touch4IT <admin@touch4it.com>"

ENV ADMIN_EMAIL webmaster@localhost

#
# PHP extensions
#

ENV PHP_TIME_ZONE UTC
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_POST_MAX_SIZE 32M

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
		acl \
		bash \
		gettext \
		git \
		libicu-dev \
		libjpeg-dev \
		libfreetype6-dev \
		libpng-dev \
		libpq-dev \
		libxml2-dev \
		libzip-dev \
		zip \
		grep \
	&& docker-php-ext-configure gd \
		--with-png=/usr/include/ \
		--with-jpeg=/usr/include/ \
		--with-freetype=/usr/include/ \
	&& docker-php-ext-configure pgsql \
		-with-pgsql=/usr/local/pgsql \
	&& docker-php-ext-configure zip \
		--with-libzip \
	&& docker-php-ext-install \
		bcmath \
		exif \
		gd \
		gettext \
		intl \
		json \
		mbstring \
		mysqli \
		opcache \
		pdo \
		pdo_mysql \
		pdo_pgsql \
		pgsql \
		zip \
    && docker-php-ext-configure bcmath --enable-bcmath

#
# CRON
#

RUN apt-get install -y --no-install-recommends cron \
	&& mkdir -m 0644 -p /etc/cron.d \
	&& mkdir -m 0644 -p /var/log/cron \
	&& touch /var/log/cron/cron.log

#
# COMPOSER
#

RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer self-update

#
# APACHE
#

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends apache2; \
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

RUN ls -l $APACHE_CONFDIR/mods-available
RUN ls -l $APACHE_CONFDIR/mods-enabled

RUN a2enmod http2 proxy_fcgi rewrite setenvif

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL WINCH

# Add configuration
COPY ./docker-vars.ini /usr/local/etc/php/conf.d/docker-vars.ini
COPY ./www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./000-default.conf $APACHE_CONFDIR/sites-available/000-default.conf

EXPOSE 80

COPY ./apache2-foreground /usr/local/bin/
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/apache2-foreground
CMD ["/entrypoint.sh"]
