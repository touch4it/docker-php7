# Drupal PHP-FPM + Nginx

Docker image tailored to run Drupal 8

## More info

Docker hub

https://hub.docker.com/r/touch4it/drupal-php-fpm-nginx

Github repository

https://github.com/touch4it/docker-php7

## What's here?

This repository is a source code for following Docker images:


* Latest release
  * touch4it/drupal-php-fpm-nginx:latest
* Production images
  * 8.5.1, 8.5, 8.5-php7.2
  * 8.4.6, 8.4, 8.4-php7.1
  * 8.5-php7.1
  * 8.4-php7.2
* Development images
  * 8.5-dev, 8.5-php7.2-dev
  * 8.4-dev, 8.4-php7.1-dev
  * 8.5-php7.1-dev
  * 8.4-php7.2-dev

# Usage

## Example Docker compose

### docker-compose.yml

```yaml
version: '2'
services:
  drupal:
    image: touch4it/drupal-php-fpm-nginx:8.5
    expose:
      - 80
    links:
      - mariadb:mariadb
    depends_on:
      - mariadb
  db:
    image: mariadb:10.1
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

Use ```docker-compose up``` command to start your development environment.

## Build production image

You can build production ready image with Dockerfile like this:

```
FROM touch4it/docker-php7:php7
ADD . /var/www/html
```

# FAQ

## What extensions are enabled by default?

### PHP

* exif
* gd
* gettext
* intl
* mbstring
* opcache
* pgsql
* pdo
* pdo_mysql
* pdo_pgsql
* zip

## How do i install additional php extensions?
This work is based on official Docker Hub `php` images. You can use docker-php-ext-install to add new extensions. More information can be found https://hub.docker.com/_/php/

## How do I change default PHP variables?
You can add an ini file into `$PHP_INI_DIR/conf.d` directory

# What other PHP images do we have?

* Debian + Apache + mod_php
  * touch4it/docker-php7:php7-apache
  * touch4it/docker-php7:php7.1-apache
  * touch4it/docker-php7:php7.2-apache
  * touch4it/php7-apache-symfony:php7
  * touch4it/php7-apache-symfony:php7.2
* Alpine + Nginx + PHP-FPM
  * touch4it/docker-php7:php7.1-fpm-nginx
  * touch4it/docker-php7:php7.1-fpm-nginx-dev
  * touch4it/docker-php7:php7.2-fpm-nginx
  * touch4it/docker-php7:php7.2-fpm-nginx-dev
  * touch4it/php-nginx-symfony:php7.1-fpm-nginx
  * touch4it/php-nginx-symfony:php7.1-fpm-nginx-dev
  * touch4it/php-nginx-symfony:php7.2-fpm-nginx
  * touch4it/php-nginx-symfony:php7.2-fpm-nginx-dev
