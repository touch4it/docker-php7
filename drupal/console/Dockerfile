FROM php:7.2-cli-alpine

LABEL maintainer="Touch4IT <admin@touch4it.com>"

COPY --from=touch4it/drupal-php-fpm-nginx:latest /usr/bin/composer /usr/bin/composer
COPY --from=touch4it/drupal-php-fpm-nginx:latest /var/www/html/vendor/drupal/console/bin/drupal /usr/local/bin/drupal

ENTRYPOINT ["drupal"]

CMD ["list"]
