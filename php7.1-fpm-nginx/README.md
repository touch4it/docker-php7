## Minimal docker-compose configuration

```yaml
www:
  image: touch4it/docker-php7:php7.1-fpm-nginx
  volumes:
    - "app:/var/www/html/web"
  ports:
    - "80"
```

## Full docker-compose configuration

```yaml
www:
  image: touch4it/docker-php7:php7.1-fpm-nginx
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
