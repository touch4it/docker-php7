FROM php:8.4.15-fpm-alpine3.22

LABEL maintainer="Touch4IT <admin@touch4it.com>"

ENV ADMIN_EMAIL=webmaster@localhost

#
# PHP extensions
#

ENV PHP_TIME_ZONE=UTC
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_UPLOAD_MAX_FILESIZE=32M
ENV PHP_POST_MAX_SIZE=32M

RUN apk update \
  && apk add --no-cache \
  acl \
  bash \
  dcron \
  freetype-dev \
  gettext-dev \
  git \
  grep \
  icu-dev \
  imagemagick \
  imagemagick-dev \
  libjpeg-turbo-dev \
  libpng-dev \
  libwebp-dev \
  libzip-dev \
  oniguruma-dev \
  patch \
  php84-dom \
  php84-xml \
  postgresql-dev \
  zip \
  ${PHPIZE_DEPS} \
  && rm -rf /var/cache/apk/*

# Install ImageMagick from source with compatible version for PHP 8.3/8.4
RUN set -xe \
  cd /tmp \
  && curl -sS https://pecl.php.net/get/imagick-3.8.0.tgz --output imagick-3.8.0.tgz \
  && tar -xzf imagick-3.8.0.tgz \
  && cd imagick-3.8.0 \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && docker-php-ext-enable imagick \
  # Clean up
  && cd .. \
  && rm -rf imagick-3.8.0 imagick-3.8.0.tgz

RUN \
  # Enable imagick when https://github.com/Imagick/imagick/issues/643 is solved
  # pecl install imagick \
  # && docker-php-ext-enable imagick \
  docker-php-ext-configure gd \
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
    zip

#
# CRON
#

RUN mkdir -m 0644 -p /etc/cron.d \
  && mkdir -m 0644 -p /var/log/cron \
  && touch /var/log/cron/cron.log

#
# COMPOSER
#
# Note: Composer installer script includes its own checksum verification
# For additional security, consider pinning to a specific version
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && chmod +x /usr/local/bin/composer

#
# NGINX
#

ENV NGINX_VERSION=1.27.5
ENV PKG_RELEASE=1
ENV DYNPKG_RELEASE=1

RUN set -x \
# create nginx user/group first, to be consistent throughout docker variants
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apkArch="$(cat /etc/apk/arch)" \
    && nginxPackages=" \
        nginx=${NGINX_VERSION}-r${PKG_RELEASE} \
    " \
# install prerequisites for public key and pkg-oss checks
    && apk add --no-cache --virtual .checksum-deps \
        openssl \
    && case "$apkArch" in \
        x86_64|aarch64) \
# arches officially built by upstream
            set -x \
            && KEY_SHA512="e09fa32f0a0eab2b879ccbbc4d0e4fb9751486eedda75e35fac65802cc9faa266425edf83e261137a2f4d16281ce2c1a5f4502930fe75154723da014214f0655" \
            && wget -O /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
            && if echo "$KEY_SHA512 */tmp/nginx_signing.rsa.pub" | sha512sum -c -; then \
                echo "key verification succeeded!"; \
                mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/; \
            else \
                echo "key verification failed!"; \
                exit 1; \
            fi \
            && apk add -X "https://nginx.org/packages/mainline/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages \
            ;; \
        *) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from the published packaging sources
            set -x \
            && tempDir="$(mktemp -d)" \
            && chown nobody:nobody $tempDir \
            && apk add --no-cache --virtual .build-deps \
                gcc \
                libc-dev \
                make \
                openssl-dev \
                pcre2-dev \
                zlib-dev \
                linux-headers \
                bash \
                alpine-sdk \
                findutils \
                curl \
            && su nobody -s /bin/sh -c " \
                export HOME=${tempDir} \
                && cd ${tempDir} \
                && curl -f -L -O https://github.com/nginx/pkg-oss/archive/${NGINX_VERSION}-${PKG_RELEASE}.tar.gz \
                && PKGOSSCHECKSUM=\"c773d98b567bd585c17f55702bf3e4c7d82b676bfbde395270e90a704dca3c758dfe0380b3f01770542b4fd9bed1f1149af4ce28bfc54a27a96df6b700ac1745 *${NGINX_VERSION}-${PKG_RELEASE}.tar.gz\" \
                && if [ \"\$(openssl sha512 -r ${NGINX_VERSION}-${PKG_RELEASE}.tar.gz)\" = \"\$PKGOSSCHECKSUM\" ]; then \
                    echo \"pkg-oss tarball checksum verification succeeded!\"; \
                else \
                    echo \"pkg-oss tarball checksum verification failed!\"; \
                    exit 1; \
                fi \
                && tar xzvf ${NGINX_VERSION}-${PKG_RELEASE}.tar.gz \
                && cd pkg-oss-${NGINX_VERSION}-${PKG_RELEASE} \
                && cd alpine \
                && make base \
                && apk index --allow-untrusted -o ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz ${tempDir}/packages/alpine/${apkArch}/*.apk \
                && abuild-sign -k ${tempDir}/.abuild/abuild-key.rsa ${tempDir}/packages/alpine/${apkArch}/APKINDEX.tar.gz \
                " \
            && cp ${tempDir}/.abuild/abuild-key.rsa.pub /etc/apk/keys/ \
            && apk del --no-network .build-deps \
            && apk add -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
            ;; \
    esac \
# remove checksum deps
    && apk del --no-network .checksum-deps \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    && if [ -n "$tempDir" ]; then rm -rf "$tempDir"; fi \
    && if [ -f "/etc/apk/keys/abuild-key.rsa.pub" ]; then rm -f /etc/apk/keys/abuild-key.rsa.pub; fi \
# Add `envsubst` for templating environment variables
    && apk add --no-cache gettext-envsubst \
# Bring in tzdata so users could set the timezones through the environment
# variables
    && apk add --no-cache tzdata \
# forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Add configuration
COPY ./docker-vars.ini /usr/local/etc/php/conf.d/docker-vars.ini
COPY ./www.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./nginx.vh.default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

STOPSIGNAL SIGQUIT

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
