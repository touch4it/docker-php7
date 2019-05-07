FROM touch4it/docker-php7:php7.3-fpm-nginx

COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

ENV DRUPAL_VERSION 8.7.0
ENV DRUPAL_MD5 f6135e49de6bc5b1f259ef3e76580dd0

RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites modules themes

RUN composer require drupal/console:~1.0 drush/drush --prefer-dist --optimize-autoloader \
	&& ln -s /var/www/html/vendor/drupal/console/bin/drupal /usr/local/bin/drupal \
	&& ln -s /var/www/html/vendor/drush/drush/drush /usr/local/bin/drush
