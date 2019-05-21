#!/bin/bash

# Build production images

docker build --no-cache ./php7.1-apache \
	-t touch4it/docker-php7:latest \
	-t touch4it/docker-php7:php7.1-apache \
	-f ./php7.1-apache/Dockerfile

docker build --no-cache ./php7.2-apache \
	-t touch4it/docker-php7:php7.2-apache \
	-f ./php7.2-apache/Dockerfile

docker build --no-cache ./php7.3-apache \
	-t touch4it/docker-php7:php7.3-apache \
	-f ./php7.3-apache/Dockerfile

docker build --no-cache ./php7.1-fpm-nginx \
	-t touch4it/docker-php7:php7.1-fpm-nginx \
	-f ./php7.1-fpm-nginx/Dockerfile

docker build --no-cache ./php7.2-fpm-nginx \
	-t touch4it/docker-php7:php7.2-fpm-nginx \
	-f ./php7.2-fpm-nginx/Dockerfile

docker build --no-cache ./php7.3-fpm-nginx \
	-t touch4it/docker-php7:php7.3-fpm-nginx \
	-f ./php7.3-fpm-nginx/Dockerfile

# Build development images

docker build ./php7.1-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.1-fpm-nginx-dev \
	-f ./php7.1-fpm-nginx-dev/Dockerfile

docker build ./php7.2-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.2-fpm-nginx-dev \
	-f ./php7.2-fpm-nginx-dev/Dockerfile

docker build ./php7.3-fpm-nginx-dev \
	-t touch4it/docker-php7:php7.3-fpm-nginx-dev \
	-f ./php7.3-fpm-nginx-dev/Dockerfile

# Deploy production images

docker push touch4it/docker-php7:php7.1-apache
docker push touch4it/docker-php7:php7.2-apache
docker push touch4it/docker-php7:php7.3-apache

docker push touch4it/docker-php7:php7.1-fpm-nginx
docker push touch4it/docker-php7:php7.2-fpm-nginx
docker push touch4it/docker-php7:php7.3-fpm-nginx

# Deploy production images

docker push touch4it/docker-php7:php7.1-fpm-nginx-dev
docker push touch4it/docker-php7:php7.2-fpm-nginx-dev
docker push touch4it/docker-php7:php7.3-fpm-nginx-dev

# Build and deploy specific images

sh ./drupal/build.sh
sh ./yii2/build.sh
