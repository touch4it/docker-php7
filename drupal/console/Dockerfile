FROM php:7.2-cli-alpine

LABEL maintainer="Touch4IT <admin@touch4it.com>"

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN composer require drupal/console:~1.0 \
    --prefer-dist \
    --optimize-autoloader \
	&& cp /var/www/html/vendor/drupal/console/bin/drupal /usr/local/bin/drupal

ENTRYPOINT ["drupal"]

CMD ["list"]
