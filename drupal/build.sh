#!/bin/bash

# Build production images

echo "Building Drupal images"

docker buildx build ./php7.4-fpm-nginx-drupal9.2 \
	-t touch4it/drupal-php-fpm-nginx:9.2-php7.4 \
	-t touch4it/drupal-php-fpm-nginx:9.2 \
	-t touch4it/drupal-php-fpm-nginx:9.2.11 \
	-f ./php7.4-fpm-nginx-drupal9.2/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-nginx-drupal9.3 \
	-t touch4it/drupal-php-fpm-nginx:9.3-php7.4 \
	-t touch4it/drupal-php-fpm-nginx:9.3 \
	-t touch4it/drupal-php-fpm-nginx:9.3.3 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php7.4-fpm-nginx-drupal9.3/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

# Build development images

docker buildx build ./php7.4-fpm-nginx-drupal9.2-dev \
	-t touch4it/drupal-php-fpm-nginx:9.2-dev \
	-t touch4it/drupal-php-fpm-nginx:9.2-php7.4-dev \
	-f ./php7.4-fpm-nginx-drupal9.2-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-nginx-drupal9.3-dev \
	-t touch4it/drupal-php-fpm-nginx:9.3-dev \
	-t touch4it/drupal-php-fpm-nginx:9.3-php7.4-dev \
	-f ./php7.4-fpm-nginx-drupal9.3-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

# Build Drupal console

docker buildx build ./console \
	-t touch4it/drupal-php-fpm-nginx:console \
	-f ./console/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1
