#!/bin/bash

# Build production images

echo "Building Drupal images"

docker build ./php7.3-fpm-nginx-drupal8.9 \
	-t touch4it/drupal-php-fpm-nginx:8.9-php7.3 \
	-t touch4it/drupal-php-fpm-nginx:8.9 \
	-t touch4it/drupal-php-fpm-nginx:8.9.12 \
	-f ./php7.3-fpm-nginx-drupal8.9/Dockerfile

docker build ./php7.4-fpm-nginx-drupal8.9 \
	-t touch4it/drupal-php-fpm-nginx:8.9-php7.4 \
	-f ./php7.4-fpm-nginx-drupal8.9/Dockerfile

docker build ./php7.4-fpm-nginx-drupal9.0 \
	-t touch4it/drupal-php-fpm-nginx:9.0-php7.4 \
	-f ./php7.4-fpm-nginx-drupal9.0/Dockerfile

docker build ./php7.4-fpm-nginx-drupal9.1 \
	-t touch4it/drupal-php-fpm-nginx:9.1-php7.4 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php7.4-fpm-nginx-drupal9.1/Dockerfile

# Build development images

docker build ./php7.3-fpm-nginx-drupal8.9-dev \
	-t touch4it/drupal-php-fpm-nginx:8.9-php7.3-dev \
	-t touch4it/drupal-php-fpm-nginx:8.9-dev \
	-f ./php7.3-fpm-nginx-drupal8.9-dev/Dockerfile

docker build ./php7.4-fpm-nginx-drupal8.9-dev \
	-t touch4it/drupal-php-fpm-nginx:8.9-php7.4-dev \
	-f ./php7.4-fpm-nginx-drupal8.9-dev/Dockerfile

docker build ./php7.4-fpm-nginx-drupal9.0-dev \
	-t touch4it/drupal-php-fpm-nginx:9.0-php7.4-dev \
	-f ./php7.4-fpm-nginx-drupal9.0-dev/Dockerfile

docker build ./php7.4-fpm-nginx-drupal9.1-dev \
	-t touch4it/drupal-php-fpm-nginx:9.1-php7.4-dev \
	-f ./php7.4-fpm-nginx-drupal9.1-dev/Dockerfile

# Build Drupal console

docker build ./console \
	-t touch4it/drupal-php-fpm-nginx:console \
	-f ./console/Dockerfile

# Push production images

echo "Pushing Drupal images"

docker push touch4it/drupal-php-fpm-nginx:latest

docker push touch4it/drupal-php-fpm-nginx:8.9.12
docker push touch4it/drupal-php-fpm-nginx:8.9
docker push touch4it/drupal-php-fpm-nginx:8.9-php7.3

docker push touch4it/drupal-php-fpm-nginx:8.9-php7.4

docker push touch4it/drupal-php-fpm-nginx:9.0.10
docker push touch4it/drupal-php-fpm-nginx:9.0
docker push touch4it/drupal-php-fpm-nginx:9.0-php7.4

docker push touch4it/drupal-php-fpm-nginx:9.1.2
docker push touch4it/drupal-php-fpm-nginx:9.1
docker push touch4it/drupal-php-fpm-nginx:9.1-php7.4

# Push dev images

docker push touch4it/drupal-php-fpm-nginx:8.9-dev
docker push touch4it/drupal-php-fpm-nginx:8.9-php7.3-dev

docker push touch4it/drupal-php-fpm-nginx:8.9-php7.4-dev

docker push touch4it/drupal-php-fpm-nginx:9.0-dev
docker push touch4it/drupal-php-fpm-nginx:9.0-php7.4-dev

docker push touch4it/drupal-php-fpm-nginx:9.1-dev
docker push touch4it/drupal-php-fpm-nginx:9.1-php7.4-dev

# Push Docker console

docker push touch4it/drupal-php-fpm-nginx:console
