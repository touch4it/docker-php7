#!/bin/bash

# Build production images

echo "Building Drupal images"

docker build ./php7.4-fpm-nginx-drupal9.2 \
	-t touch4it/drupal-php-fpm-nginx:9.2-php7.4 \
	-t touch4it/drupal-php-fpm-nginx:9.2 \
	-t touch4it/drupal-php-fpm-nginx:9.2.11 \
	-f ./php7.4-fpm-nginx-drupal9.2/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php7.4-fpm-nginx-drupal9.3 \
	-t touch4it/drupal-php-fpm-nginx:9.3-php7.4 \
	-t touch4it/drupal-php-fpm-nginx:9.3 \
	-t touch4it/drupal-php-fpm-nginx:9.3.3 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php7.4-fpm-nginx-drupal9.3/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Build development images

docker build ./php7.4-fpm-nginx-drupal9.2-dev \
	-t touch4it/drupal-php-fpm-nginx:9.2-dev \
	-t touch4it/drupal-php-fpm-nginx:9.2-php7.4-dev \
	-f ./php7.4-fpm-nginx-drupal9.2-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php7.4-fpm-nginx-drupal9.3-dev \
	-t touch4it/drupal-php-fpm-nginx:9.3-dev \
	-t touch4it/drupal-php-fpm-nginx:9.3-php7.4-dev \
	-f ./php7.4-fpm-nginx-drupal9.3-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Build Drupal console

docker build ./console \
	-t touch4it/drupal-php-fpm-nginx:console \
	-f ./console/Dockerfile \
	--platform linux/amd64 \
	|| exit 1


# Push production images

echo "Pushing Drupal images"

docker push touch4it/drupal-php-fpm-nginx:latest

docker push touch4it/drupal-php-fpm-nginx:9.2.11
docker push touch4it/drupal-php-fpm-nginx:9.2
docker push touch4it/drupal-php-fpm-nginx:9.2-php7.4

docker push touch4it/drupal-php-fpm-nginx:9.3.3
docker push touch4it/drupal-php-fpm-nginx:9.3
docker push touch4it/drupal-php-fpm-nginx:9.3-php7.4

# Push dev images

docker push touch4it/drupal-php-fpm-nginx:9.2-dev
docker push touch4it/drupal-php-fpm-nginx:9.2-php7.4-dev

docker push touch4it/drupal-php-fpm-nginx:9.3-dev
docker push touch4it/drupal-php-fpm-nginx:9.3-php7.4-dev

# Push Docker console

docker push touch4it/drupal-php-fpm-nginx:console
