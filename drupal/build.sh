#!/bin/bash

# Build production images

echo "Building Drupal images"

docker build ./php8.1-fpm-nginx-drupal9.4 \
	-t touch4it/drupal-php-fpm-nginx:9.4 \
	-t touch4it/drupal-php-fpm-nginx:9.4.11 \
	-t touch4it/drupal-php-fpm-nginx:9.4-php8.1 \
	-t touch4it/drupal-php-fpm-nginx:9.4.11-php8.1 \
	-f ./php8.1-fpm-nginx-drupal9.4/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.1-fpm-nginx-drupal9.5 \
	-t touch4it/drupal-php-fpm-nginx:9.5 \
	-t touch4it/drupal-php-fpm-nginx:9.5.3 \
	-t touch4it/drupal-php-fpm-nginx:9.5-php8.1 \
	-t touch4it/drupal-php-fpm-nginx:9.5.3-php8.1 \
	-f ./php8.1-fpm-nginx-drupal9.5/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.1-fpm-nginx-drupal10.0 \
	-t touch4it/drupal-php-fpm-nginx:10.0 \
	-t touch4it/drupal-php-fpm-nginx:10.0.3 \
	-t touch4it/drupal-php-fpm-nginx:10.0-php8.1 \
	-t touch4it/drupal-php-fpm-nginx:10.0.3-php8.1 \
	-t touch4it/drupal-php-fpm-nginx:latest \
	-f ./php8.1-fpm-nginx-drupal10.0/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Build development images

docker build ./php8.1-fpm-nginx-drupal9.4-dev \
	-t touch4it/drupal-php-fpm-nginx:9.4-dev \
	-t touch4it/drupal-php-fpm-nginx:9.4-php8.1-dev \
	-f ./php8.1-fpm-nginx-drupal9.4-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.1-fpm-nginx-drupal9.5-dev \
	-t touch4it/drupal-php-fpm-nginx:9.5-dev \
	-t touch4it/drupal-php-fpm-nginx:9.5-php8.1-dev \
	-f ./php8.1-fpm-nginx-drupal9.5-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.1-fpm-nginx-drupal10.0-dev \
	-t touch4it/drupal-php-fpm-nginx:10.0-dev \
	-t touch4it/drupal-php-fpm-nginx:10.0-php8.1-dev \
	-f ./php8.1-fpm-nginx-drupal10.0-dev/Dockerfile \
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

docker push touch4it/drupal-php-fpm-nginx:9.4.11
docker push touch4it/drupal-php-fpm-nginx:9.4
docker push touch4it/drupal-php-fpm-nginx:9.4.11-php8.1
docker push touch4it/drupal-php-fpm-nginx:9.4-php8.1

docker push touch4it/drupal-php-fpm-nginx:9.5.3
docker push touch4it/drupal-php-fpm-nginx:9.5
docker push touch4it/drupal-php-fpm-nginx:9.5.3-php8.1
docker push touch4it/drupal-php-fpm-nginx:9.5-php8.1

docker push touch4it/drupal-php-fpm-nginx:10.0.3
docker push touch4it/drupal-php-fpm-nginx:10.0
docker push touch4it/drupal-php-fpm-nginx:10.0.3-php8.1
docker push touch4it/drupal-php-fpm-nginx:10.0-php8.1

# Push dev images

docker push touch4it/drupal-php-fpm-nginx:9.4-dev
docker push touch4it/drupal-php-fpm-nginx:9.4-php8.1-dev

docker push touch4it/drupal-php-fpm-nginx:9.5-dev
docker push touch4it/drupal-php-fpm-nginx:9.5-php8.1-dev

docker push touch4it/drupal-php-fpm-nginx:10.0-dev
docker push touch4it/drupal-php-fpm-nginx:10.0-php8.1-dev

# Push Docker console

docker push touch4it/drupal-php-fpm-nginx:console
