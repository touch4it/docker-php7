FROM --platform=$BUILDPLATFORM touch4it/docker-php7:php7.4-fpm-nginx

COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

ENV DRUPAL_VERSION 9.2.11
ENV DRUPAL_MD5 13647faa6fdc286ff753b4a0c785db01

RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites modules themes

RUN /usr/local/bin/php -d memory_limit=-1 /usr/local/bin/composer require drupal/console drush/drush --prefer-dist --optimize-autoloader
RUN ln -s /var/www/html/vendor/drupal/console/bin/drupal /usr/local/bin/drupal \
	&& chmod a+x /usr/local/bin/drupal \
	&& ln -s /var/www/html/vendor/drush/drush/drush /usr/local/bin/drush \
	&& chmod a+x /usr/local/bin/drush
