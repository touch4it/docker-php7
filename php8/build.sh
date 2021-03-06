#!/bin/bash

# Build production images

echo "Building PHP 8 images"

## Apache + mod_php

docker build ./php8.0-apache \
	-t touch4it/php8:php8.0-apache \
	-t touch4it/php8:php8-apache \
	-t touch4it/php8:latest-apache \
	-f ./php8.0-apache/Dockerfile

## Apache + FPM

docker build ./php8.0-fpm-apache \
	-t touch4it/php8:php8.0-fpm-apache \
	-t touch4it/php8:php8-fpm-apache \
	-t touch4it/php8:latest-fpm-apache \
	-f ./php8.0-fpm-apache/Dockerfile

## Nginx + FPM

docker build ./php8.0-fpm-nginx \
	-t touch4it/php8:php8.0-fpm-nginx \
	-t touch4it/php8:php8-fpm-nginx \
	-t touch4it/php8:latest-fpm-nginx \
	-t touch4it/php8:latest \
	-f ./php8.0-fpm-nginx/Dockerfile

# Deploy production images

echo "Pushing PHP images"

docker push touch4it/php8:php8.0-apache
docker push touch4it/php8:php8-apache
docker push touch4it/php8:latest-apache

docker push touch4it/php8:php8.0-fpm-apache
docker push touch4it/php8:php8-fpm-apache
docker push touch4it/php8:latest-fpm-apache

docker push touch4it/php8:php8.0-fpm-nginx
docker push touch4it/php8:php8-fpm-nginx
docker push touch4it/php8:latest-fpm-nginx
docker push touch4it/php8:latest

# Build development images

docker build ./php8.0-fpm-nginx-dev \
	-t touch4it/php8:php8.0-fpm-nginx-dev \
	-t touch4it/php8:php8-fpm-nginx-dev \
	-t touch4it/php8:latest-fpm-nginx-dev \
	-t touch4it/php8:latest-dev \
	-f ./php8.0-fpm-nginx-dev/Dockerfile

# Deploy development images

docker push touch4it/php8:php8.0-fpm-nginx-dev
docker push touch4it/php8:php8-fpm-nginx-dev
docker push touch4it/php8:latest-fpm-nginx-dev
docker push touch4it/php8:latest-dev
