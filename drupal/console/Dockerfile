FROM --platform=$BUILDPLATFORM php:7.3.33-cli-alpine

LABEL maintainer="Touch4IT <admin@touch4it.com>"

COPY --from=touch4it/drupal-php-fpm-nginx:latest /usr/local/bin/composer /usr/local/bin/composer
COPY --from=touch4it/drupal-php-fpm-nginx:latest /var/www/html/vendor/drupal/console/bin/drupal /usr/local/bin/drupal
COPY --from=touch4it/drupal-php-fpm-nginx:latest /var/www/html/vendor/drush/drush/drush /usr/local/bin/drush

ENTRYPOINT ["drupal"]

CMD ["list"]
