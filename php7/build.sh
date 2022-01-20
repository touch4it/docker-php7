#!/bin/bash

# Build production images

echo "Building PHP 7 images"

## Apache + mod_php

docker buildx build ./php7.3-apache \
	-t touch4it/docker-php7:php7.3-apache \
	-t touch4it/docker-php7:php7.3.33-apache \
	-f ./php7.3-apache/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-apache \
	-t touch4it/docker-php7:php7.4-apache \
	-t touch4it/docker-php7:php7.4.27-apache \
	-t touch4it/docker-php7:latest-apache \
	-f ./php7.4-apache/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

## Apache + FPM

docker buildx build ./php7.3-fpm-apache \
	-t touch4it/docker-php7:php7.3-fpm-apache \
	-t touch4it/docker-php7:php7.3.33-fpm-apache \
	-f ./php7.3-fpm-apache/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-apache \
	-t touch4it/docker-php7:php7.4-fpm-apache \
	-t touch4it/docker-php7:php7.4.27-fpm-apache \
	-t touch4it/docker-php7:latest-fpm-apache \
	-f ./php7.4-fpm-apache/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

## Nginx + FPM

docker buildx build ./php7.3-fpm-nginx \
	-t touch4it/docker-php7:php7.3-fpm-nginx \
	-t touch4it/docker-php7:php7.3.33-fpm-nginx \
	-f ./php7.3-fpm-nginx/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-nginx \
	-t touch4it/docker-php7:php7.4-fpm-nginx \
	-t touch4it/docker-php7:php7.4.27-fpm-nginx \
	-t touch4it/docker-php7:latest-fpm-nginx \
	-t touch4it/docker-php7:latest \
	-f ./php7.4-fpm-nginx/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

# Build development images

docker buildx build ./php7.3-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.3-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.3.33-fpm-nginx-dev \
	-f ./php7.3-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.4-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.4.27-fpm-nginx-dev \
	-t touch4it/docker-php7:latest-fpm-nginx-dev \
	-t touch4it/docker-php7:latest-dev \
	-f ./php7.4-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1
