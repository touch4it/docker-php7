FROM php:5-apache
ADD apache2.conf /etc/apache2/apache2.conf
ADD symfony.ini /usr/local/etc/php/conf.d/symfony.ini

RUN apt-get update \
        && apt-get install -y libicu-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql opcache intl && a2enmod rewrite && mkdir /var/www/html/web