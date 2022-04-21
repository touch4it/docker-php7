FROM  touch4it/docker-php7:php7.4-fpm-nginx

COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

ENV DRUPAL_VERSION 9.2.18
ENV DRUPAL_MD5 58f546a0d25dad5f3d5cac55a300d2f5

RUN curl -fSL "https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites modules themes

RUN /usr/local/bin/php -d memory_limit=-1 /usr/local/bin/composer global require \
	drupal/console \
	drush/drush \
	--prefer-dist --optimize-autoloader

RUN ln -s /root/.composer/vendor/drupal/console/bin/drupal /usr/local/bin/drupal \
	&& chmod a+x /usr/local/bin/drupal \
	&& ln -s /root/.composer/vendor/drush /usr/local/bin/drush \
	&& chmod a+x /usr/local/bin/drush
