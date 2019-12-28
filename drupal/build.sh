#!/bin/bash

# Build production images

echo "Building Drupal images"

docker build --no-cache ./php7.3-fpm-nginx-drupal8.8 \
	-t touch4it/drupal-php-fpm-nginx:8.8-php7.3 \
	-t touch4it/drupal-php-fpm-nginx:8.8 \
	-t touch4it/drupal-php-fpm-nginx:8.8.1 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php7.3-fpm-nginx-drupal8.8/Dockerfile

docker build --no-cache ./php7.3-fpm-nginx-drupal8.7 \
	-t touch4it/drupal-php-fpm-nginx:8.7-php7.3 \
	-t touch4it/drupal-php-fpm-nginx:8.7 \
	-t touch4it/drupal-php-fpm-nginx:8.7.11 \
	-f ./php7.3-fpm-nginx-drupal8.7/Dockerfile

# Build development images

docker build ./php7.3-fpm-nginx-drupal8.8-dev \
	-t touch4it/drupal-php-fpm-nginx:8.8-php7.3-dev \
	-t touch4it/drupal-php-fpm-nginx:8.8-dev \
	-f ./php7.3-fpm-nginx-drupal8.8-dev/Dockerfile

docker build ./php7.3-fpm-nginx-drupal8.7-dev \
	-t touch4it/drupal-php-fpm-nginx:8.7-php7.3-dev \
	-t touch4it/drupal-php-fpm-nginx:8.7-dev \
	-f ./php7.3-fpm-nginx-drupal8.7-dev/Dockerfile

# Build Drupal console

docker build --no-cache ./console \
	-t touch4it/drupal-php-fpm-nginx:console \
	-f ./console/Dockerfile

# Push production images

echo "Pushing Drupal images"

docker push touch4it/drupal-php-fpm-nginx:latest

docker push touch4it/drupal-php-fpm-nginx:8.8.1
docker push touch4it/drupal-php-fpm-nginx:8.8
docker push touch4it/drupal-php-fpm-nginx:8.8-php7.3

docker push touch4it/drupal-php-fpm-nginx:8.7.11
docker push touch4it/drupal-php-fpm-nginx:8.7
docker push touch4it/drupal-php-fpm-nginx:8.7-php7.3

# Push dev images

docker push touch4it/drupal-php-fpm-nginx:8.8-dev
docker push touch4it/drupal-php-fpm-nginx:8.8-php7.3-dev

docker push touch4it/drupal-php-fpm-nginx:8.7-dev
docker push touch4it/drupal-php-fpm-nginx:8.7-php7.3-dev

# Push Docker console

docker push touch4it/drupal-php-fpm-nginx:console
