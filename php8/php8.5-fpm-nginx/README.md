# Extended PHP image

Docker image tailored to run PHP application. Check https://hub.docker.com/r/touch4it/docker-php7

## Tags

PHP 8

* Debian + Apache + mod_php
  * touch4it/php8:php8.1-apache
  * touch4it/php8:php8.2-apache
  * touch4it/php8:php8.3-apache
  * touch4it/php8:php8.4-apache
  * touch4it/php8:php8.5-apache
  * touch4it/php8:php8-apache
  * touch4it/php8:latest-apache
* Debian + Apache + PHP-FPM
  * touch4it/php8:php8.1-fpm-apache
  * touch4it/php8:php8.2-fpm-apache
  * touch4it/php8:php8.3-fpm-apache
  * touch4it/php8:php8.4-fpm-apache
  * touch4it/php8:php8.5-fpm-apache
  * touch4it/php8:php8-fpm-apache
  * touch4it/php8:latest-fpm-apache
* Alpine + Nginx + PHP-FPM
  * touch4it/php8:latest
  * touch4it/php8:php8.1-fpm-nginx
  * touch4it/php8:php8.1-fpm-nginx-dev
  * touch4it/php8:php8.2-fpm-nginx
  * touch4it/php8:php8.2-fpm-nginx-dev
  * touch4it/php8:php8.3-fpm-nginx
  * touch4it/php8:php8.3-fpm-nginx-dev
  * touch4it/php8:php8.4-fpm-nginx
  * touch4it/php8:php8.4-fpm-nginx-dev
  * touch4it/php8:php8.5-fpm-nginx
  * touch4it/php8:php8.5-fpm-nginx-dev
  * touch4it/php8:php8-fpm-nginx
  * touch4it/php8:latest-fpm-nginx
  * touch4it/php8:php8-fpm-nginx-dev
  * touch4it/php8:latest-fpm-nginx-dev
  * touch4it/php8:latest-dev

## Usage

### Development env with docker-compose.yml

You can you this docker-compose.yml file to develop:

```yaml
www:
  image: touch4it/php8:php8.2-fpm-nginx
  volumes:
    - "app:/var/www/html/web"
  ports:
    - "80"
```

Of course, you are free to add linked containers like database, caching etc.

Use ```docker-compose up``` command to start your development environment.

### Full docker-compose configuration

```yaml
www:
  image: touch4it/php8:php8.2-fpm-nginx
  volumes:
    - "app:/var/www/html/web"
    - "php.ini:/usr/local/etc/php/conf.d/docker-vars.ini"
    - "www.conf:/usr/local/etc/php-fpm.d/www.conf"
    - "nginx.conf:/etc/nginx/nginx.conf"
    - "nginx.vh.default.conf:/etc/nginx/conf.d/default.conf"
    - "nginx.custom.conf:/etc/nginx/conf.d/custom.conf"
    - "nginx.other-custom.conf:/etc/nginx/conf.d/other-custom.conf"
  ports:
    - "80"
```

### Build production image

You can build production ready image with Dockerfile like this:

```dockerfile
FROM touch4it/docker-php7:latest
ADD . /var/www/html
```

### Environment variables

This image uses several environment variables which are easy to miss. While none of the variables are required, they may significantly aid you in using the image.

#### `ADMIN_EMAIL`

The ServerAdmin sets the contact address that the server includes in any error messages it returns to the client.
If the httpd doesn't recognize the supplied argument as an URL, it assumes, that it's an email-address and prepends it with `mailto:` in hyperlink targets.
However, it's recommended to actually use an email address, since there are a lot of CGI scripts that make that assumption.
If you want to use an URL, it should point to another server under your control. Otherwise users may not be able to contact you in case of errors.

Default value: `webmaster@localhost`

For Apache-based images

#### `PHP_TIME_ZONE`

Defines the default timezone used by the date functions

http://php.net/date.timezone

Default value: `Europe/London`

#### `PHP_MEMORY_LIMIT`

Maximum amount of memory a script may consume

http://php.net/memory-limit

Default value: `256M`

#### `PHP_UPLOAD_MAX_FILESIZE`

Maximum allowed size for uploaded files.

http://php.net/upload-max-filesize

Default value: `32M`

#### `PHP_POST_MAX_SIZE`

Maximum size of POST data that PHP will accept.
Its value may be 0 to disable the limit.
It is ignored if POST data reading is disabled through enable_post_data_reading.

http://php.net/post-max-size

Default value: `32M`

## FAQ

### What extensions are enabled by default?

#### Apache

* mod_rewrite

For Apache-based images

* mod_http2

for Apache 2.4.26+ based images

#### PHP

* bcmath
* exif
* gd
* gettext
* imagick (installed via PIE)
* intl
* mbstring
* opcache
* pgsql
* pdo
* pdo_mysql
* pdo_pgsql
* zip

### How do I install additional php extensions?

This work is based on official Docker Hub `php` images. You can use docker-php-ext-install to add new extensions. More information can be found https://hub.docker.com/_/php/

#### PIE (PHP Installer/Extension)

Starting with PHP 8.4 and 8.5 fpm-nginx images, we've integrated [PIE](https://github.com/php/pie) - the modern PHP extension installer. PIE simplifies the installation of PHP extensions from Packagist.

**Images with PIE:**

* touch4it/php8:php8.4-fpm-nginx
* touch4it/php8:php8.5-fpm-nginx

**Usage example:**

```dockerfile
FROM touch4it/php8:php8.4-fpm-nginx
RUN pie install vendor/package:^1.0
```

PIE uses Composer-style package names from Packagist and handles compilation, installation, and enabling extensions automatically.

### How do I change default PHP variables?

You can add an ini file into `$PHP_INI_DIR/conf.d` directory

### Why is my .htaccess file not working?

Check if you have not selected Nginx-based image

### What Apache version is on Apache-based images?

Same as in similar official PHP image on Docker Hub

### What Nginx version is on Nginx-based images?

1.27.5

### What other PHP images do we have?

* Drupal
  * https://hub.docker.com/r/touch4it/drupal-php-fpm-nginx
* Symfony
  * https://hub.docker.com/r/touch4it/php-nginx-symfony
