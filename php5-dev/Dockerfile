FROM php:5-apache
ADD apache2.conf /etc/apache2/apache2.conf
ADD timezone.ini /usr/local/etc/php/conf.d/timezone.ini

RUN docker-php-ext-install pdo pdo_mysql opcache && a2enmod rewrite && mkdir /var/www/html/web

RUN pecl install xdebug && \
    echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini