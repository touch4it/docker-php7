#!/bin/bash

# Build production images

echo "Building Symfony images"

## Apache + mod_php

docker buildx build ./php7.3 \
	-t touch4it/php7-apache-symfony:php7.3 \
	-f ./php7.3/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4 \
	-t touch4it/php7-apache-symfony:php7.4 \
	-t touch4it/php7-apache-symfony:latest \
	-f ./php7.4/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

## Nginx + FPM

docker buildx build ./php7.3-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.3-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.3 \
	-f ./php7.3-fpm-nginx/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.4-fpm-nginx \
	-t touch4it/php-nginx-symfony:php7.4 \
	-t touch4it/php-nginx-symfony:latest \
	-f ./php7.4-fpm-nginx/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

# Build development images

docker buildx build ./php7.3-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.3-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.3-dev \
	-f ./php7.3-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.4-fpm-nginx-dev \
	-t touch4it/php-nginx-symfony:php7.4-dev \
	-t touch4it/php-nginx-symfony:latest-dev \
	-f ./php7.4-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1
