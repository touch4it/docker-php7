FROM  touch4it/docker-php7:php7.4-fpm-nginx

ENV VERSION_COMPOSER_ASSET_PLUGIN=^1.4.6
ENV MEMCACHED_DEPS zlib-dev libmemcached-dev cyrus-sasl-dev

# Memcached
RUN apk add --no-cache --update libmemcached-libs zlib
RUN set -xe \
    && apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .memcached-deps $MEMCACHED_DEPS \
    && pecl install memcached \
    && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini \
    && rm -rf /usr/share/php7 \
    && rm -rf /tmp/* \
    && apk del .memcached-deps .phpize-deps

# apcu
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

# set recommended apcu PHP.ini settings
# see https://secure.php.net/manual/en/apcu.configuration.php
RUN { \
	echo 'apc.shm_segments=1'; \
	echo 'apc.shm_size=256M'; \
	echo 'apc.num_files_hint=7000'; \
	echo 'apc.user_entries_hint=4096'; \
	echo 'apc.ttl=7200'; \
	echo 'apc.user_ttl=7200'; \
	echo 'apc.gc_ttl=3600'; \
	echo 'apc.max_file_size=1M'; \
	echo 'apc.stat=1'; \
} > $PHP_INI_DIR/conf.d/apcu-recommended.ini

RUN composer global require --optimize-autoloader \
		"fxp/composer-asset-plugin:${VERSION_COMPOSER_ASSET_PLUGIN}"

COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
