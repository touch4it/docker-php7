FROM touch4it/docker-php7:php7.3-fpm-nginx

COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf
COPY --from=drupal:8.5.15-fpm-alpine /var/www/html /var/www/html

RUN composer require drupal/console:~1.0 drush/drush \
    --prefer-dist \
    --optimize-autoloader \
	&& ln -s /var/www/html/vendor/drupal/console/bin/drupal /usr/local/bin/drupal \
	&& ln -s /var/www/html/vendor/drush/drush/drush /usr/local/bin/drush

WORKDIR /var/www/html

RUN chown -R www-data:www-data sites modules themes
