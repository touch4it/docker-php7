FROM touch4it/php8:php8.1-fpm-nginx

COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

RUN composer global config --no-plugins allow-plugins.composer/installers true
RUN composer global config --no-plugins allow-plugins.drupal/core-composer-scaffold true
RUN composer global config --no-plugins allow-plugins.drupal/core-project-message true
RUN composer global config --no-plugins  allow-plugins.drupal/console-extend-plugin true

ENV DRUPAL_VERSION 10.0.11
ENV DRUPAL_MD5 3e8d274d025f819e86d0800b18a44f8c

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
