#!/bin/bash

# Build production images
docker build ./php7.2-fpm-nginx-drupal8.5 \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.2 \
	-t touch4it/drupal-php-fpm-nginx:8.5 \
	-t touch4it/drupal-php-fpm-nginx:8.5.1 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php7.2-fpm-nginx-drupal8.5/Dockerfile

docker build ./php7.1-fpm-nginx-drupal8.5 \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.1 \
	-f ./php7.1-fpm-nginx-drupal8.5/Dockerfile

docker build ./php7.2-fpm-nginx-drupal8.4 \
	-t touch4it/drupal-php-fpm-nginx:8.4-php7.2 \
	-f ./php7.2-fpm-nginx-drupal8.4/Dockerfile

docker build ./php7.1-fpm-nginx-drupal8.4 \
	-t touch4it/drupal-php-fpm-nginx:8.4-php7.1 \
	-t touch4it/drupal-php-fpm-nginx:8.4 \
	-t touch4it/drupal-php-fpm-nginx:8.4.6 \
	-f ./php7.1-fpm-nginx-drupal8.4/Dockerfile

# Build development images
docker build ./php7.2-fpm-nginx-drupal8.5-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.2-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-dev \
	-f ./php7.2-fpm-nginx-drupal8.5-dev/Dockerfile

docker build ./php7.1-fpm-nginx-drupal8.5-dev \
	-t touch4it/drupal-php-fpm-nginx:8.5-php7.1-dev \
	-f ./php7.1-fpm-nginx-drupal8.5-dev/Dockerfile

docker build ./php7.2-fpm-nginx-drupal8.4-dev \
	-t touch4it/drupal-php-fpm-nginx:8.4-php7.2-dev \
	-f ./php7.2-fpm-nginx-drupal8.4-dev/Dockerfile

docker build ./php7.1-fpm-nginx-drupal8.4-dev \
	-t touch4it/drupal-php-fpm-nginx:8.4-php7.1-dev \
	-t touch4it/drupal-php-fpm-nginx:8.4-dev \
	-f ./php7.1-fpm-nginx-drupal8.4-dev/Dockerfile

# Deploy production images
docker push touch4it/drupal-php-fpm-nginx:latest
docker push touch4it/drupal-php-fpm-nginx:8.5.1
docker push touch4it/drupal-php-fpm-nginx:8.5
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.2
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.1
docker push touch4it/drupal-php-fpm-nginx:8.4.6
docker push touch4it/drupal-php-fpm-nginx:8.4
docker push touch4it/drupal-php-fpm-nginx:8.4-php7.1
docker push touch4it/drupal-php-fpm-nginx:8.4-php7.2

# Deploy dev images
docker push touch4it/drupal-php-fpm-nginx:8.5-dev
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.2-dev
docker push touch4it/drupal-php-fpm-nginx:8.5-php7.1-dev
docker push touch4it/drupal-php-fpm-nginx:8.4-dev
docker push touch4it/drupal-php-fpm-nginx:8.4-php7.1-dev
docker push touch4it/drupal-php-fpm-nginx:8.4-php7.2-dev
