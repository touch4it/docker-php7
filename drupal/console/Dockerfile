FROM  php:7.3.33-cli-alpine

LABEL maintainer="Touch4IT <admin@touch4it.com>"

COPY --from=touch4it/drupal-php-fpm-nginx:latest /usr/local/bin/composer /usr/local/bin/composer
COPY --from=touch4it/drupal-php-fpm-nginx:latest /root/.composer/vendor/drupal/console/bin/drupal /usr/local/bin/drupal
COPY --from=touch4it/drupal-php-fpm-nginx:latest /root/.composer/vendor/drush /usr/local/bin/drush

ENTRYPOINT ["drupal"]

CMD ["list"]
