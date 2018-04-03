FROM touch4it/docker-php7:php7.2-fpm-nginx

COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf
COPY --from=drupal:8.4.6-fpm-alpine /var/www/html /var/www/html

WORKDIR /var/www/html

RUN chown -R www-data:www-data sites modules themes
