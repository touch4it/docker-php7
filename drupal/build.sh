#!/bin/bash

# Build production images

docker build --no-cache ./php7.3-fpm-nginx-drupal8.7 \
	-t touch4it/drupal-php-fpm-nginx:8.7-php7.3 \
	-t touch4it/drupal-php-fpm-nginx:8.7 \
	-t touch4it/drupal-php-fpm-nginx:8.7.1 \
	-f ./php7.3-fpm-nginx-drupal8.7/Dockerfile

docker build --no-cache ./php7.2-fpm-nginx-drupal8.6 \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.2 \
	-t touch4it/drupal-php-fpm-nginx:8.6 \
	-t touch4it/drupal-php-fpm-nginx:8.6.16 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php7.2-fpm-nginx-drupal8.6/Dockerfile

docker build --no-cache ./php7.3-fpm-nginx-drupal8.6 \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.3 \
	-f ./php7.3-fpm-nginx-drupal8.6/Dockerfile

docker build --no-cache ./php7.3-fpm-nginx-drupal8.5 \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.3 \
	-f ./php7.3-fpm-nginx-drupal8.5/Dockerfile

# Build development images

docker build --no-cache ./php7.3-fpm-nginx-drupal8.7-dev \
	-t touch4it/drupal-php-fpm-nginx:8.7-php7.3-dev \
	-t touch4it/drupal-php-fpm-nginx:8.7-dev \
	-f ./php7.3-fpm-nginx-drupal8.7-dev/Dockerfile

docker build --no-cache ./php7.2-fpm-nginx-drupal8.6-dev \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.2-dev \
	-t touch4it/drupal-php-fpm-nginx:8.6-dev \
	-f ./php7.2-fpm-nginx-drupal8.6-dev/Dockerfile

docker build --no-cache ./php7.3-fpm-nginx-drupal8.6-dev \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.3-dev \
	-f ./php7.3-fpm-nginx-drupal8.6-dev/Dockerfile

docker build --no-cache ./php7.2-fpm-nginx-drupal8.5-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.2-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-dev \
	-f ./php7.2-fpm-nginx-drupal8.5-dev/Dockerfile

# Build Drupal console

docker build --no-cache ./console \
	-t touch4it/drupal-php-fpm-nginx:console \
	-f ./console/Dockerfile

# Deploy production images

docker push touch4it/drupal-php-fpm-nginx:latest

docker push touch4it/drupal-php-fpm-nginx:8.7.1
docker push touch4it/drupal-php-fpm-nginx:8.7
docker push touch4it/drupal-php-fpm-nginx:8.7-php7.3

docker push touch4it/drupal-php-fpm-nginx:8.6.16
docker push touch4it/drupal-php-fpm-nginx:8.6
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.2
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.3

docker push touch4it/drupal-php-fpm-nginx:8.5.15
docker push touch4it/drupal-php-fpm-nginx:8.5
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.2

# Deploy dev images

docker push touch4it/drupal-php-fpm-nginx:8.7-dev
docker push touch4it/drupal-php-fpm-nginx:8.7-php7.3-dev

docker push touch4it/drupal-php-fpm-nginx:8.6-dev
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.2-dev
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.3-dev

docker push touch4it/drupal-php-fpm-nginx:8.5-dev
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.2-dev

# Deploy Docker console

docker push touch4it/drupal-php-fpm-nginx:console
