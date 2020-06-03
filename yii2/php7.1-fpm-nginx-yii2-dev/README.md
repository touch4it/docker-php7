# Yii2 PHP-FPM + Nginx

Docker image tailored to run Yii2

## More info

Docker hub

https://hub.docker.com/r/touch4it/yii2-php-fpm-nginx

Github repository

https://github.com/touch4it/docker-php7

## What's here?

This repository is a source code for following Docker images tagged by PHP version:

* Production images
  * touch4it/yii2-php-fpm-nginx:7
  * touch4it/yii2-php-fpm-nginx:7.1, latest
  * touch4it/yii2-php-fpm-nginx:7.2
* Development images
  * touch4it/yii2-php-fpm-nginx:7-dev
  * touch4it/yii2-php-fpm-nginx:7.1-dev
  * touch4it/yii2-php-fpm-nginx:7.2-dev

# Usage

## Example Docker compose

### docker-compose.yml

```yaml
version: '2'
services:
  drupal:
    image: touch4it/yii2-php-fpm-nginx
    expose:
      - 80
    links:
      - db:db
    depends_on:
      - db
  db:
    image: mariadb:10.3
    environment:
      MYSQL_ROOT_PASSWORD: yii
      MYSQL_DATABASE: yii
      MYSQL_USER: yii
      MYSQL_PASSWORD: yii
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
      - ./app:/var/www/html
      - ./cron:/etc/cron
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

* apcu
* exif
* gd
* gettext
* intl
* mbstring
* memcached
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
  * touch4it/docker-php7:php7.1-apache
  * touch4it/docker-php7:php7.2-apache
  * touch4it/docker-php7:php7.3-apache
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
  * touch4it/php-nginx-symfony:php7.3-fpm-nginx
  * touch4it/php-nginx-symfony:php7.3-fpm-nginx-dev
* Drupal
  * touch4it/drupal-php-fpm-nginx:latest, 8.8, 8.8-php7.3
  * touch4it/drupal-php-fpm-nginx:8.8-php7.4
  * touch4it/drupal-php-fpm-nginx:8.7
