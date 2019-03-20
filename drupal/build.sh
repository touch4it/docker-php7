#!/bin/bash

# Build production images

docker build ./php7.2-fpm-nginx-drupal8.6 \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.2 \
	-t touch4it/drupal-php-fpm-nginx:8.6 \
	-t touch4it/drupal-php-fpm-nginx:8.6.12 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php7.2-fpm-nginx-drupal8.6/Dockerfile

docker build ./php7.3-fpm-nginx-drupal8.6 \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.3 \
	-f ./php7.3-fpm-nginx-drupal8.6/Dockerfile

docker build ./php7.3-fpm-nginx-drupal8.5 \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.3 \
	-f ./php7.3-fpm-nginx-drupal8.5/Dockerfile

# Build development images

docker build ./php7.2-fpm-nginx-drupal8.6-dev \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.2-dev \
	-t touch4it/drupal-php-fpm-nginx:8.6-dev \
	-f ./php7.2-fpm-nginx-drupal8.6-dev/Dockerfile

docker build ./php7.3-fpm-nginx-drupal8.6-dev \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.3-dev \
	-f ./php7.3-fpm-nginx-drupal8.6-dev/Dockerfile

docker build ./php7.2-fpm-nginx-drupal8.5-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.2-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-dev \
	-f ./php7.2-fpm-nginx-drupal8.5-dev/Dockerfile

# Build Drupal console

docker build ./console \
	-t touch4it/drupal-php-fpm-nginx:console \
	-f ./console/Dockerfile

# Deploy production images

docker push touch4it/drupal-php-fpm-nginx:latest

docker push touch4it/drupal-php-fpm-nginx:8.6.12
docker push touch4it/drupal-php-fpm-nginx:8.6
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.2
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.3

docker push touch4it/drupal-php-fpm-nginx:8.5.13
docker push touch4it/drupal-php-fpm-nginx:8.5
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.2

# Deploy dev images

docker push touch4it/drupal-php-fpm-nginx:8.6-dev
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.2-dev
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.3-dev

docker push touch4it/drupal-php-fpm-nginx:8.5-dev
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.2-dev

# Deploy Docker console

docker push touch4it/drupal-php-fpm-nginx:console
