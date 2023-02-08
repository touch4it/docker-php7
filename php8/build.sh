#!/bin/bash

# Build production images

echo "Building PHP 8 images"

## Apache + mod_php

docker build ./php8.0-apache \
	-t touch4it/php8:php8.0.27-apache \
	-t touch4it/php8:php8.0-apache \
	-f ./php8.0-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.1-apache \
	-t touch4it/php8:php8.1.15-apache \
	-t touch4it/php8:php8.1-apache \
	-f ./php8.1-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.2-apache \
	-t touch4it/php8:php8.2.2-apache \
	-t touch4it/php8:php8.2-apache \
	-t touch4it/php8:php8-apache \
	-t touch4it/php8:latest-apache \
	-f ./php8.2-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

## Apache + FPM

docker build ./php8.0-fpm-apache \
	-t touch4it/php8:php8.0.27-fpm-apache \
	-t touch4it/php8:php8.0-fpm-apache \
	-f ./php8.0-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.1-fpm-apache \
	-t touch4it/php8:php8.1.15-fpm-apache \
	-t touch4it/php8:php8.1-fpm-apache \
	-t touch4it/php8:php8-fpm-apache \
	-f ./php8.1-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.2-fpm-apache \
	-t touch4it/php8:php8.2.2-fpm-apache \
	-t touch4it/php8:php8.2-fpm-apache \
	-t touch4it/php8:php8-fpm-apache \
	-t touch4it/php8:latest-fpm-apache \
	-f ./php8.2-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

## Nginx + FPM

docker build ./php8.0-fpm-nginx \
	-t touch4it/php8:php8.0.27-fpm-nginx \
	-t touch4it/php8:php8.0-fpm-nginx \
	-f ./php8.0-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.1-fpm-nginx \
	-t touch4it/php8:php8.1.15-fpm-nginx \
	-t touch4it/php8:php8.1-fpm-nginx \
	-t touch4it/php8:php8-fpm-nginx \
	-f ./php8.1-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.2-fpm-nginx \
	-t touch4it/php8:php8.2.2-fpm-nginx \
	-t touch4it/php8:php8.2-fpm-nginx \
	-t touch4it/php8:php8-fpm-nginx \
	-t touch4it/php8:latest-fpm-nginx \
	-t touch4it/php8:latest \
	-f ./php8.2-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Build development images

docker build ./php8.0-fpm-nginx-dev \
	-t touch4it/php8:php8.0.27-fpm-nginx-dev \
	-t touch4it/php8:php8.0-fpm-nginx-dev \
	-f ./php8.0-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.1-fpm-nginx-dev \
	-t touch4it/php8:php8.1.15-fpm-nginx-dev \
	-t touch4it/php8:php8.1-fpm-nginx-dev \
	-t touch4it/php8:php8-fpm-nginx-dev \
	-f ./php8.1-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.2-fpm-nginx-dev \
	-t touch4it/php8:php8.2.2-fpm-nginx-dev \
	-t touch4it/php8:php8.2-fpm-nginx-dev \
	-t touch4it/php8:php8-fpm-nginx-dev \
	-t touch4it/php8:latest-fpm-nginx-dev \
	-t touch4it/php8:latest-dev \
	-f ./php8.2-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Deploy production images

echo "Pushing PHP images"

docker push touch4it/php8:php8.0.27-apache
docker push touch4it/php8:php8.0-apache

docker push touch4it/php8:php8.1.15-apache
docker push touch4it/php8:php8.1-apache

docker push touch4it/php8:php8.2.2-apache
docker push touch4it/php8:php8.2-apache

docker push touch4it/php8:php8-apache
docker push touch4it/php8:latest-apache

docker push touch4it/php8:php8.0.27-fpm-apache
docker push touch4it/php8:php8.0-fpm-apache

docker push touch4it/php8:php8.1.15-fpm-apache
docker push touch4it/php8:php8.1-fpm-apache

docker push touch4it/php8:php8.2.2-fpm-apache
docker push touch4it/php8:php8.2-fpm-apache

docker push touch4it/php8:php8-fpm-apache
docker push touch4it/php8:latest-fpm-apache

docker push touch4it/php8:php8.0.27-fpm-nginx
docker push touch4it/php8:php8.0-fpm-nginx

docker push touch4it/php8:php8.1.15-fpm-nginx
docker push touch4it/php8:php8.1-fpm-nginx

docker push touch4it/php8:php8.2.2-fpm-nginx
docker push touch4it/php8:php8.2-fpm-nginx

docker push touch4it/php8:php8-fpm-nginx
docker push touch4it/php8:latest-fpm-nginx
docker push touch4it/php8:latest

# Deploy development images

docker push touch4it/php8:php8.0.27-fpm-nginx-dev
docker push touch4it/php8:php8.0-fpm-nginx-dev

docker push touch4it/php8:php8.1.15-fpm-nginx-dev
docker push touch4it/php8:php8.1-fpm-nginx-dev

docker push touch4it/php8:php8.2.2-fpm-nginx-dev
docker push touch4it/php8:php8.2-fpm-nginx-dev

docker push touch4it/php8:php8-fpm-nginx-dev
docker push touch4it/php8:latest-fpm-nginx-dev
docker push touch4it/php8:latest-dev
