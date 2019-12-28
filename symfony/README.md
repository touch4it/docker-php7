# PHP 7 - Symfony docker images
Docker image tailored to run Symfony application.

Apache: https://hub.docker.com/r/touch4it/php7-apache-symfony

Nginx: https://hub.docker.com/r/touch4it/php-nginx-symfony/

## What's here?

This repository is a source code for following docker images that allow relatively easily work with symfony php framework. Included images:

* Apache + mod_php
** touch4it/php7-apache-symfony:php7.4
** touch4it/php7-apache-symfony:php7.3
** touch4it/php7-apache-symfony:php7.2
* Nginx + FPM
** touch4it/php-nginx-symfony:php7.4-fpm-nginx
** touch4it/php-nginx-symfony:php7.4-fpm-nginx-dev
** touch4it/php-nginx-symfony:php7.3-fpm-nginx
** touch4it/php-nginx-symfony:php7.3-fpm-nginx-dev
** touch4it/php-nginx-symfony:php7.2-fpm-nginx
** touch4it/php-nginx-symfony:php7.2-fpm-nginx-dev

# Usage

## Development env with docker-compose.yml

You can you this docker-compose.yml file to develop:

```
www:
  image: touch4it/php7-apache-symfony:php7
  volumes:
    - ".:/var/www/html"
  ports:
    - "80:80"
```
Of course you are free to add linked containers like database, caching etc.

## Adjust your symfony app kernel to write cache and logs to /tmp dir
```
    public function getCacheDir()
    {
        return sys_get_temp_dir().'/cache/'.$this->getEnvironment();
    }

    public function getLogDir()
    {
        return sys_get_temp_dir().'/logs/'.$this->getEnvironment();
    }
```

## Make symfony log to stderr

```yaml
monolog:
    handlers:
        main:
            type: stream
            path: "php://stderr"
            level: debug
            channels: ['!event', '!doctrine']
        doctrine:
            type: stream
            path: "php://stderr"
            level: debug
            channels: ['doctrine']
        console:
            type: console
            channels: ['!event', '!doctrine']
```

You also need to set `error_log = /proc/self/fd/2` in your php.ini (docker-vars.ini)

Use ```docker-compose up``` command to start your development environment.

## Output logs to stderr (optional)

You may want to adjust config_dev and config_prod to output logs to stderr (so they will be handled correctly by docker)
``
path:  "php://stderr"
``

## Build production image

You can build production ready image with dockerfile like this:

```
FROM touch4it/php7-apache-symfony:php7
ADD . /var/www/html
# Add your application build steps here, for example:
# RUN ./var/www/html/web/bin/...
RUN rm -rf /var/www/html/web/app_dev.php
RUN rm -rf /var/www/html/web/config.php
```

## Environment variables

This image uses several environment variables which are easy to miss. While none of the variables are required, they may significantly aid you in using the image.

### `APACHE_ADMIN_EMAIL`

The ServerAdmin sets the contact address that the server includes in any error messages it returns to the client.
If the httpd doesn't recognize the supplied argument as an URL, it assumes, that it's an email-address and prepends it with `mailto:` in hyperlink targets.
However, it's recommended to actually use an email address, since there are a lot of CGI scripts that make that assumption.
If you want to use an URL, it should point to another server under your control. Otherwise users may not be able to contact you in case of errors.

Default value: `webmaster@localhost`

### `PHP_TIME_ZONE`

Defines the default timezone used by the date functions

http://php.net/date.timezone

Default value: `Europe/London`

### `PHP_MEMORY_LIMIT`

Maximum amount of memory a script may consume

http://php.net/memory-limit

Default value: `256M`

### `PHP_UPLOAD_MAX_FILESIZE`

Maximum allowed size for uploaded files.

http://php.net/upload-max-filesize

Default value: `32M`

### `PHP_POST_MAX_SIZE`

Maximum size of POST data that PHP will accept.
Its value may be 0 to disable the limit.
It is ignored if POST data reading is disabled through enable_post_data_reading.

http://php.net/post-max-size

Default value: `32M`

# FAQ

## What extensions are enabled by default?

### Apache

* mod_rewrite

### PHP

* exif
* gd
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

## Why can't i access app_dev.php?
By default symfony block requests to app_dev.php that come from non localhost sources. You can change that editing app_dev.php file.
