FROM php:8.4.27-fpm-alpine3.24

LABEL maintainer="Touch4IT <admin@touch4it.com>"

ENV ADMIN_EMAIL=webmaster@localhost

#
# PHP extensions
#

ENV PHP_TIME_ZONE=UTC
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_UPLOAD_MAX_FILESIZE=32M
ENV PHP_POST_MAX_SIZE=32M

ENV PIE_VERSION=1.4.7
ENV PIE_SHA256=e8d27c100e85720f374a55f79d63fa8d686dedabc9ccbc6567085e0baf646d55
RUN wget -O pie.phar https://github.com/php/pie/releases/download/${PIE_VERSION}/pie.phar \
  && echo "${PIE_SHA256}  pie.phar" | sha256sum -c - \
  && chmod +x pie.phar \
  && mv pie.phar /usr/local/bin/pie

RUN apk add --no-cache \
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
  postgresql-dev \
  zip \
  ${PHPIZE_DEPS}

RUN pie install imagick/imagick:3.8.1 --with-imagick=/usr

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
  && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
  && docker-php-ext-configure bcmath --enable-bcmath \
  && docker-php-ext-install -j"$(nproc)" \
    bcmath \
    exif \
    gd \
    gettext \
    intl \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    zip

# dom/xml/opcache ship enabled in the base image; fail the build if that ever changes
RUN for ext in dom xml libxml SimpleXML xmlreader xmlwriter "Zend OPcache"; do \
    php -m | grep -qix "$ext" || { echo "ERROR: PHP extension $ext missing"; exit 1; }; \
  done

#
# CRON
#

RUN mkdir -m 0755 -p /etc/cron.d \
  && mkdir -m 0755 -p /var/log/cron \
  && touch /var/log/cron/cron.log

#
# COMPOSER
#
# Install Composer (verify installer signature before running)
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
  && EXPECTED="$(curl -sS https://composer.github.io/installer.sig)" \
  && ACTUAL="$(php -r "echo hash_file('sha384', 'composer-setup.php');")" \
  && [ "$EXPECTED" = "$ACTUAL" ] || { echo 'ERROR: Invalid composer installer checksum'; exit 1; } \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && rm composer-setup.php

#
# NGINX
#

ENV NGINX_VERSION=1.30.6
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
# we need to make sure nginx.org packages are pulled in, which isnt guaranteed
# as Alpine repos might have the same version in the repos.
# query nginx.org binaries for the dependencies
            && DEPS=$(apk query --summarize depends --recursive --no-cache \
                       --repository "@nginxorg https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" \
                       ${nginxPackages/=/@nginxorg=}) \
# install those dependencies from Alpine repos
            && apk add --no-cache $DEPS \
# limit apk to nginx.org repos only to install the requested packages
            && apk add --repositories-file /dev/null -X "https://nginx.org/packages/alpine/v$(egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release)/main" --no-cache $nginxPackages \
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
                && PKGOSSCHECKSUM=\"c16280934a44f7358992d39bb1d876a58e978c58371b96fd212de3f58c7ba40c31a683c54ee46c85d0844ca18fd7addeafbb29a8e06a9d1e164a8628a4739eee *${NGINX_VERSION}-${PKG_RELEASE}.tar.gz\" \
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
# same as in the "arches officially built by upstream" block, we want to make
# sure the packages we've just built will get installed
            && DEPS=$(apk query --summarize depends --recursive --no-cache \
                       --repository "@nginxorg ${tempDir}/packages/alpine/" \
                       ${nginxPackages/=/@nginxorg=}) \
            && apk add --no-cache $DEPS \
            && apk add --repositories-file /dev/null -X ${tempDir}/packages/alpine/ --no-cache $nginxPackages \
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

RUN apk upgrade && rm -rf /var/cache/apk/*

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
