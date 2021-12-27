#!/bin/bash

# Build production images

echo "Building PHP 7 images"

## Apache + mod_php

docker build ./php7.3-apache \
	-t touch4it/docker-php7:php7.3-apache \
	-t touch4it/docker-php7:php7.3.33-apache \
	-f ./php7.3-apache/Dockerfile \
	|| exit 1

docker build ./php7.4-apache \
	-t touch4it/docker-php7:php7.4-apache \
	-t touch4it/docker-php7:php7.4.27-apache \
	-t touch4it/docker-php7:latest-apache \
	-f ./php7.4-apache/Dockerfile \
	|| exit 1

## Apache + FPM

docker build ./php7.3-fpm-apache \
	-t touch4it/docker-php7:php7.3-fpm-apache \
	-t touch4it/docker-php7:php7.3.33-fpm-apache \
	-f ./php7.3-fpm-apache/Dockerfile \
	|| exit 1

docker build ./php7.4-fpm-apache \
	-t touch4it/docker-php7:php7.4-fpm-apache \
	-t touch4it/docker-php7:php7.4.27-fpm-apache \
	-t touch4it/docker-php7:latest-fpm-apache \
	-f ./php7.4-fpm-apache/Dockerfile \
	|| exit 1

## Nginx + FPM

docker build ./php7.3-fpm-nginx \
	-t touch4it/docker-php7:php7.3-fpm-nginx \
	-t touch4it/docker-php7:php7.3.33-fpm-nginx \
	-f ./php7.3-fpm-nginx/Dockerfile \
	|| exit 1

docker build ./php7.4-fpm-nginx \
	-t touch4it/docker-php7:php7.4-fpm-nginx \
	-t touch4it/docker-php7:php7.4.27-fpm-nginx \
	-t touch4it/docker-php7:latest-fpm-nginx \
	-t touch4it/docker-php7:latest \
	-f ./php7.4-fpm-nginx/Dockerfile \
	|| exit 1

# Build development images

docker build ./php7.3-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.3-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.3.33-fpm-nginx-dev \
	-f ./php7.3-fpm-nginx-dev/Dockerfile \
	|| exit 1

docker build ./php7.4-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.4-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.4.27-fpm-nginx-dev \
	-t touch4it/docker-php7:latest-fpm-nginx-dev \
	-t touch4it/docker-php7:latest-dev \
	-f ./php7.4-fpm-nginx-dev/Dockerfile \
	|| exit 1

# Deploy production images

echo "Pushing PHP images"

docker push touch4it/docker-php7:php7.3-apache
docker push touch4it/docker-php7:php7.3.33-apache
docker push touch4it/docker-php7:php7.4-apache
docker push touch4it/docker-php7:php7.4.27-apache
docker push touch4it/docker-php7:latest-apache

docker push touch4it/docker-php7:php7.3-fpm-apache
docker push touch4it/docker-php7:php7.3.33-fpm-apache
docker push touch4it/docker-php7:php7.4-fpm-apache
docker push touch4it/docker-php7:php7.4.27-fpm-apache
docker push touch4it/docker-php7:latest-fpm-apache

docker push touch4it/docker-php7:php7.3-fpm-nginx
docker push touch4it/docker-php7:php7.3.33-fpm-nginx
docker push touch4it/docker-php7:php7.4-fpm-nginx
docker push touch4it/docker-php7:php7.4.27-fpm-nginx
docker push touch4it/docker-php7:latest-fpm-nginx
docker push touch4it/docker-php7:latest

# Deploy development images

docker push touch4it/docker-php7:php7.3-fpm-nginx-dev
docker push touch4it/docker-php7:php7.3.33-fpm-nginx-dev
docker push touch4it/docker-php7:php7.4-fpm-nginx-dev
docker push touch4it/docker-php7:php7.4.27-fpm-nginx-dev
docker push touch4it/docker-php7:latest-fpm-nginx-dev
docker push touch4it/docker-php7:latest-dev
