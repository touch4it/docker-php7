#!/bin/bash

# Build production images

echo "Building PHP 7 images"

## Apache + mod_php

docker build ./php7.4-apache \
	-t touch4it/docker-php7:php7.4-apache \
	-t touch4it/docker-php7:php7.4.30-apache \
	-t touch4it/docker-php7:latest-apache \
	-f ./php7.4-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

## Apache + FPM

docker build ./php7.4-fpm-apache \
	-t touch4it/docker-php7:php7.4-fpm-apache \
	-t touch4it/docker-php7:php7.4.30-fpm-apache \
	-t touch4it/docker-php7:latest-fpm-apache \
	-f ./php7.4-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

## Nginx + FPM

docker build ./php7.4-fpm-nginx \
	-t touch4it/docker-php7:php7.4-fpm-nginx \
	-t touch4it/docker-php7:php7.4.30-fpm-nginx \
	-t touch4it/docker-php7:latest-fpm-nginx \
	-t touch4it/docker-php7:latest \
	-f ./php7.4-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Build development images

docker build ./php7.4-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.4-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.4.30-fpm-nginx-dev \
	-t touch4it/docker-php7:latest-fpm-nginx-dev \
	-t touch4it/docker-php7:latest-dev \
	-f ./php7.4-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Deploy production images

echo "Pushing PHP images"

docker push touch4it/docker-php7:php7.4-apache
docker push touch4it/docker-php7:php7.4.30-apache
docker push touch4it/docker-php7:latest-apache

docker push touch4it/docker-php7:php7.4-fpm-apache
docker push touch4it/docker-php7:php7.4.30-fpm-apache
docker push touch4it/docker-php7:latest-fpm-apache

docker push touch4it/docker-php7:php7.4-fpm-nginx
docker push touch4it/docker-php7:php7.4.30-fpm-nginx
docker push touch4it/docker-php7:latest-fpm-nginx
docker push touch4it/docker-php7:latest

# Deploy development images

docker push touch4it/docker-php7:php7.4-fpm-nginx-dev
docker push touch4it/docker-php7:php7.4.30-fpm-nginx-dev
docker push touch4it/docker-php7:latest-fpm-nginx-dev
docker push touch4it/docker-php7:latest-dev
