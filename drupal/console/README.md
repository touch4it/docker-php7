# Drupal PHP-FPM + Nginx

Docker image tailored to run Drupal 8

## More info

[Docker hub](https://hub.docker.com/r/touch4it/drupal-php-fpm-nginx)

[Github repository](https://github.com/touch4it/docker-php7)

## What's here?

This repository is a source code for following Docker images:

* Latest release
  * touch4it/drupal-php-fpm-nginx:latest
* Production images
  * latest, 9.4.7, 9.4, 9.4-php8.1
  * latest, 9.3.22, 9.3, 9.3-php7.4
* Development images
  * 9.4-dev
  * 9.3-dev
* Drupal console
  * console
* Legacy images
  * 9.2, 9.2-php7.4
  * 9.1, 9.1-php7.4
  * 9.0, 9.0-php7.4
  * 8.8, 8.8-php7.3
  * 8.8-php7.4
  * 8.7, 8.7-php7.3
  * 8.6, 8.6-php7.2, 8.6-php7.3
  * 8.5, 8.5-php7.2
  * 8.4, 8.4-php7.2
  * 8.3, 8.3-php7.1

# Usage

## Example Docker compose

### docker-compose.yml

```yaml
version: '2'
services:
  drupal:
    image: touch4it/drupal-php-fpm-nginx:latest
    expose:
      - 80
    links:
      - mariadb:mariadb
    depends_on:
      - mariadb
  db:
    image: mariadb:10.3
    environment:
      MYSQL_ROOT_PASSWORD: drupal
      MYSQL_DATABASE: drupal
      MYSQL_USER: drupal
      MYSQL_PASSWORD: drupal
    expose:
      - 3306
```

### docker-compose.override.yml

```yaml
version: '2'

services:
  drupal:
    ports:
      - 8080:80
    volumes:
      - ./drupal/private:/var/www/private
      - ./drupal/sites:/var/www/html/sites
      - ./drupal/themes:/var/www/html/themes
      - ./drupal/modules:/var/www/html/modules
      - ./drupal/libraries:/var/www/html/libraries
      - ./drupal/etc/php/local.ini:/usr/local/etc/php/conf.d/local.ini

  db:
    volumes:
      - ./db/init:/docker-entrypoint-initdb.d
      - ./db/data:/var/lib/mysql
      - ./db/dump:/dump
```

Use `docker-compose up` command to start your development environment.

# Using Drupal console

You can directly execute Drupal Console commands from image command line, e.g.

```
drupal cache:rebuild
```

or

```
/var/www/html/vendor/drupal/console/bin/drupal cache:rebuild
```

## Build production image

You can build production ready image with Dockerfile like this:

```
FROM touch4it/drupal-php-fpm-nginx:latest
ADD . /var/www/html
```

# FAQ

## What extensions are enabled by default?

### PHP

*   exif
*   gd
*   gettext
*   intl
*   mbstring
*   opcache
*   pgsql
*   pdo
*   pdo_mysql
*   pdo_pgsql
*   zip

## How do i install additional php extensions?

This work is based on official Docker Hub `php` images. You can use docker-php-ext-install to add new extensions. More information can be found https://hub.docker.com/_/php/

## How do I change default PHP variables?

You can add an ini file into `$PHP_INI_DIR/conf.d` directory

# What other PHP images do we have?

PHP 7

* Debian + Apache + mod_php
  * touch4it/docker-php7:php7.3-apache
  * touch4it/docker-php7:php7.4-apache
* Debian + Apache + PHP-FPM
  * touch4it/docker-php7:php7.3-fpm-apache
  * touch4it/docker-php7:php7.4-fpm-apache
* Alpine + Nginx + PHP-FPM
  * touch4it/docker-php7:php7.3-fpm-nginx
  * touch4it/docker-php7:php7.3-fpm-nginx-dev
  * touch4it/docker-php7:php7.4-fpm-nginx
  * touch4it/docker-php7:php7.4-fpm-nginx-dev

PHP 8

* Debian + Apache + mod_php
  * touch4it/php8:php8.0-apache
  * touch4it/php8:php8.1-apache
* Debian + Apache + PHP-FPM
  * touch4it/php8:php8.0-fpm-apache
  * touch4it/php8:php8.1-fpm-apache
* Alpine + Nginx + PHP-FPM
  * touch4it/php8:latest
  * touch4it/php8:php8.0-fpm-nginx
  * touch4it/php8:php8.0-fpm-nginx-dev
  * touch4it/php8:php8.1-fpm-nginx
  * touch4it/php8:php8.1-fpm-nginx-dev
* Symfony
  * touch4it/php7-apache-symfony:php7.3
  * touch4it/php7-apache-symfony:php7.4
  * touch4it/php-nginx-symfony:php7.3-fpm-nginx
  * touch4it/php-nginx-symfony:php7.3-fpm-nginx-dev
  * touch4it/php-nginx-symfony:latest, php7.4-fpm-nginx
  * touch4it/php-nginx-symfony:php7.4-fpm-nginx-dev
