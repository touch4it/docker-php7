#!/bin/bash

# Build production images

echo "Building PHP 8 images"

## Apache + mod_php

docker buildx build ./php8.0-apache \
	-t touch4it/php8:php8.0.14-apache \
	-t touch4it/php8:php8.0-apache \
	-t touch4it/php8:php8-apache \
	-t touch4it/php8:latest-apache \
	-f ./php8.0-apache/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

## Apache + FPM

docker buildx build ./php8.0-fpm-apache \
	-t touch4it/php8:php8.0.14-fpm-apache \
	-t touch4it/php8:php8.0-fpm-apache \
	-t touch4it/php8:php8-fpm-apache \
	-t touch4it/php8:latest-fpm-apache \
	-f ./php8.0-fpm-apache/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

## Nginx + FPM

docker buildx build ./php8.0-fpm-nginx \
	-t touch4it/php8:php8.0.14-fpm-nginx \
	-t touch4it/php8:php8.0-fpm-nginx \
	-t touch4it/php8:php8-fpm-nginx \
	-t touch4it/php8:latest-fpm-nginx \
	-t touch4it/php8:latest \
	-f ./php8.0-fpm-nginx/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

# Build development images

docker buildx build ./php8.0-fpm-nginx-dev \
	-t touch4it/php8:php8.0.14-fpm-nginx-dev \
	-t touch4it/php8:php8.0-fpm-nginx-dev \
	-t touch4it/php8:php8-fpm-nginx-dev \
	-t touch4it/php8:latest-fpm-nginx-dev \
	-t touch4it/php8:latest-dev \
	-f ./php8.0-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1
