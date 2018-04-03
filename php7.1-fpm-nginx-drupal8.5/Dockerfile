FROM touch4it/docker-php7:php7.1-fpm-nginx

COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf
COPY --from=drupal:8.5.1-fpm-alpine /var/www/html /var/www/html

RUN cd ~ && \
	curl https://drupalconsole.com/installer -L -o drupal.phar && \
	mv drupal.phar /usr/local/bin/drupal && \
	chmod +x /usr/local/bin/drupal && \
	drupal self-update

WORKDIR /var/www/html

RUN chown -R www-data:www-data sites modules themes
