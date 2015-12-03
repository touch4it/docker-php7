FROM php:5-apache
ADD apache2.conf /etc/apache2/apache2.conf
ADD custom.ini /usr/local/etc/php/conf.d

RUN docker-php-ext-install pdo pdo_mysql opcache && a2enmod rewrite && mkdir /var/www/html/web