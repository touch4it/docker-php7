## docker-compose.yml

```yaml
version: '2'
services:
  php:
    image: touch4it/drupal-php-fpm-nginx:8.4-php7.2
    expose:
      - 80
    links:
      - mariadb:mariadb
    depends_on:
      - mariadb
  mariadb:
    image: mariadb:10.1.26
    environment:
      MYSQL_ROOT_PASSWORD: drupal
      MYSQL_DATABASE: drupal
      MYSQL_USER: drupal
      MYSQL_PASSWORD: drupal
    expose:
      - 3306
```

## docker-compose.override.yml

```yaml
version: '2'
services:
  apache:
    ports:
      - 8080:80
    volumes:
      - ./drupal/etc/passwd:/etc/passwd
      - ./drupal/private:/var/www/private
      - ./drupal/sites:/var/www/html/sites
      - ./drupal/themes:/var/www/html/themes
      - ./drupal/modules:/var/www/html/modules
      - ./drupal/libraries:/var/www/html/libraries
      - ./drupal/etc/php/local.ini:/usr/local/etc/php/conf.d/local.ini
  mariadb:
    volumes:
      - ./db/init:/docker-entrypoint-initdb.d
      - ./db/data:/var/lib/mysql
      - ./db/dump:/dump
```
