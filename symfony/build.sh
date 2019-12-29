#!/bin/bash

# Build production images

echo "Building Symfony images"

## Apache + mod_php

docker build ./php7.2 \
	-t touch4it/php7-apache-symfony:php7.2 \
	-f ./php7.2/Dockerfile

docker build ./php7.3 \
	-t touch4it/php7-apache-symfony:php7.3 \
	-f ./php7.3/Dockerfile

docker build ./php7.4 \
	-t touch4it/php7-apache-symfony:php7.4 \
	-t touch4it/php7-apache-symfony:latest \
	-f ./php7.4/Dockerfile

## Nginx + FPM

docker build ./php7.2-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.2-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.2 \
	-f ./php7.2-fpm-nginx/Dockerfile

docker build ./php7.3-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.3-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.3 \
	-f ./php7.3-fpm-nginx/Dockerfile

docker build ./php7.4-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.4-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.4 \
	-t touch4it/php-nginx-symfony:latest \
	-f ./php7.4-fpm-nginx/Dockerfile

# Build development images

docker build ./php7.2-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.2-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.2-dev \
	-f ./php7.2-fpm-nginx-dev/Dockerfile

docker build ./php7.3-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.3-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.3-dev \
	-f ./php7.3-fpm-nginx-dev/Dockerfile

docker build ./php7.4-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.4-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.4-dev \
	-t touch4it/php-nginx-symfony:latest-dev \
	-f ./php7.4-fpm-nginx-dev/Dockerfile

# Push production images

echo "Pushing Symfony images"

docker push touch4it/php7-apache-symfony:php7.2
docker push touch4it/php7-apache-symfony:php7.3
docker push touch4it/php7-apache-symfony:php7.4
docker push touch4it/php7-apache-symfony:latest

docker push touch4it/php-nginx-symfony:php7.2-fpm-nginx
docker push touch4it/php-nginx-symfony:php7.2
docker push touch4it/php-nginx-symfony:php7.3-fpm-nginx
docker push touch4it/php-nginx-symfony:php7.3
docker push touch4it/php-nginx-symfony:php7.4-fpm-nginx
docker push touch4it/php-nginx-symfony:php7.4
docker push touch4it/php-nginx-symfony:latest

# Push development images

docker push touch4it/php-nginx-symfony:php7.2-fpm-nginx-dev
docker push touch4it/php-nginx-symfony:php7.2-dev
docker push touch4it/php-nginx-symfony:php7.3-fpm-nginx-dev
docker push touch4it/php-nginx-symfony:php7.3-dev
docker push touch4it/php-nginx-symfony:php7.4-fpm-nginx-dev
docker push touch4it/php-nginx-symfony:php7.4-dev
docker push touch4it/php-nginx-symfony:latest-dev
