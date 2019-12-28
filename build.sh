#!/bin/bash

# Build production images

echo "Building PHP images"

## Apache + mod_php

docker build --no-cache ./php7.2-apache \
	-t touch4it/docker-php7:php7.2-apache \
	-f ./php7.2-apache/Dockerfile

docker build --no-cache ./php7.3-apache \
	-t touch4it/docker-php7:php7.3-apache \
	-f ./php7.3-apache/Dockerfile

## Apache + FPM

docker build --no-cache ./php7.3-fpm-apache \
	-t touch4it/docker-php7:php7.3-fpm-apache \
	-f ./php7.3-fpm-apache/Dockerfile

docker build --no-cache ./php7.4-fpm-apache \
	-t touch4it/docker-php7:php7.4-fpm-apache \
	-f ./php7.4-fpm-apache/Dockerfile

## Nginx + FPM

docker build --no-cache ./php7.2-fpm-nginx \
	-t touch4it/docker-php7:php7.2-fpm-nginx \
	-f ./php7.2-fpm-nginx/Dockerfile

docker build --no-cache ./php7.3-fpm-nginx \
	-t touch4it/docker-php7:php7.3-fpm-nginx \
	-f ./php7.3-fpm-nginx/Dockerfile

docker build --no-cache ./php7.4-fpm-nginx \
	-t touch4it/docker-php7:php7.4-fpm-nginx \
	-f ./php7.4-fpm-nginx/Dockerfile

# Build development images

docker build ./php7.2-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.2-fpm-nginx-dev \
	-f ./php7.2-fpm-nginx-dev/Dockerfile

docker build ./php7.3-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.3-fpm-nginx-dev \
	-f ./php7.3-fpm-nginx-dev/Dockerfile

docker build ./php7.4-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.4-fpm-nginx-dev \
	-f ./php7.4-fpm-nginx-dev/Dockerfile

# Deploy production images

echo "Pushing PHP images"

docker push touch4it/docker-php7:php7.2-apache
docker push touch4it/docker-php7:php7.3-apache
docker push touch4it/docker-php7:php7.4-apache

docker push touch4it/docker-php7:php7.3-fpm-apache
docker push touch4it/docker-php7:php7.4-fpm-apache

docker push touch4it/docker-php7:php7.2-fpm-nginx
docker push touch4it/docker-php7:php7.3-fpm-nginx
docker push touch4it/docker-php7:php7.4-fpm-nginx

# Deploy development images

docker push touch4it/docker-php7:php7.2-fpm-nginx-dev
docker push touch4it/docker-php7:php7.3-fpm-nginx-dev
docker push touch4it/docker-php7:php7.4-fpm-nginx-dev

# Build and deploy specific images

(cd ./drupal/ ; sh build.sh)
(cd ./yii2/ ; sh build.sh)
(cd ./symfony/ ; sh build.sh)
