#!/bin/bash

# Build production images

docker build ./php7.2-fpm-nginx-drupal8.6 \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.2 \
	-t touch4it/drupal-php-fpm-nginx:8.6 \
	-t touch4it/drupal-php-fpm-nginx:8.6.2 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php7.2-fpm-nginx-drupal8.6/Dockerfile

docker build ./php7.2-fpm-nginx-drupal8.5 \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.2 \
	-t touch4it/drupal-php-fpm-nginx:8.5 \
	-t touch4it/drupal-php-fpm-nginx:8.5.8 \
	-t touch4it/drupal-php-fpm-nginx:8.5.8-1 \
	-f ./php7.2-fpm-nginx-drupal8.5/Dockerfile

# Build development images

docker build ./php7.2-fpm-nginx-drupal8.6-dev \
	-t touch4it/drupal-php-fpm-nginx:8.6-php7.2-dev \
	-t touch4it/drupal-php-fpm-nginx:8.6-dev \
	-f ./php7.2-fpm-nginx-drupal8.6-dev/Dockerfile

docker build ./php7.2-fpm-nginx-drupal8.5-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.2-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-dev \
	-f ./php7.2-fpm-nginx-drupal8.5-dev/Dockerfile

# Deploy production images

docker push touch4it/drupal-php-fpm-nginx:latest

docker push touch4it/drupal-php-fpm-nginx:8.6.2
docker push touch4it/drupal-php-fpm-nginx:8.6
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.2

docker push touch4it/drupal-php-fpm-nginx:8.5.8
docker push touch4it/drupal-php-fpm-nginx:8.5
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.2

# Deploy dev images

docker push touch4it/drupal-php-fpm-nginx:8.6-dev
docker push touch4it/drupal-php-fpm-nginx:8.6-php7.2-dev

docker push touch4it/drupal-php-fpm-nginx:8.5-dev
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.2-dev
