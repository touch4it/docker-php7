# Basic setup

## docker-compose.yml

```yaml
version: '2'
services:
  php:
    image: touch4it/php-nginx-symfony:php7.2-fpm-nginx
    expose:
      - 80
```

## docker-compose.override.yml

```yaml
version: '2'
services:
  php:
    volumes:
      - .:/var/www/html
    ports:
      - 8080:80
```

# Image customization

## Dockerfile

```
FROM touch4it/php-nginx-symfony:php7.2-fpm-nginx-symfony

RUN /bin/su -s /bin/bash -c 'composer install -o -a' www-data
RUN /bin/su -s /bin/bash -c 'composer dump-autoload --optimize --no-dev --classmap-authoritative' www-data
RUN service cron start
```

## docker-vars.ini

```
date.timezone = "UTC"
memory_limit = 128M
short_open_tag = off
max_execution_time = 1200
upload_max_filesize = 32M
post_max_size = 32M
display_errors = Off
display_startup_errors = Off
expose_php = Off
error_prepend_string = null
error_append_string = null
error_log = /proc/self/fd/2
opcache.enable = 1
opcache.memory_consumption = 256
opcache.max_accelerated_files = 50000
opcache.validate_timestamps = 0
realpath_cache_size = 16384k
realpath_cache_ttl = 86400
```

## cron

```
# leave last two lines empty
5 0 * * * www-data cd /var/www/html && /usr/local/bin/php -d memory_limit=-1 bin/console debug:router


```

## entrypoint.sh

```
#!/usr/bin/env bash

php-fpm &
crond -c /etc/cron.d/ -f &
nginx -g "daemon off;"

```

don't forget to make entrypoint.sh executable `chmod +x entrypoint.sh`

## docker-compose.yml

```yaml
version: '2'
services:
  php:
    build: .
    volumes:
      - ./docker-vars.ini:/usr/local/etc/php/conf.d/docker-vars.ini
      - ./entrypoint.sh:/entrypoint.sh
    expose:
      - 80
```

## docker-compose.yml

```yaml
version: '2'
services:
  php:
    volumes:
      - .:/var/www/html
      - ./cron:/etc/cron.d/cron
    ports:
      - 8080:80
```
