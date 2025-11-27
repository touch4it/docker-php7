#!/bin/bash

# Build production images

echo "Building PHP 8 images"

## Apache + mod_php

docker build ./php8.1-apache \
	-t touch4it/php8:php8.1.33-apache \
	-t touch4it/php8:php8.1-apache \
	-f ./php8.1-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.2-apache \
	-t touch4it/php8:php8.2.29-apache \
	-t touch4it/php8:php8.2-apache \
	-f ./php8.2-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.3-apache \
	-t touch4it/php8:php8.3.28-apache \
	-t touch4it/php8:php8.3-apache \
	-t touch4it/php8:php8-apache \
	-f ./php8.3-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.4-apache \
	-t touch4it/php8:php8.4.15-apache \
	-t touch4it/php8:php8.4-apache \
	-f ./php8.4-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.5-apache \
	-t touch4it/php8:php8.5.0-apache \
	-t touch4it/php8:php8.5-apache \
	-t touch4it/php8:php8-apache \
	-t touch4it/php8:latest-apache \
	-f ./php8.5-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

## Apache + FPM

docker build ./php8.1-fpm-apache \
	-t touch4it/php8:php8.1.33-fpm-apache \
	-t touch4it/php8:php8.1-fpm-apache \
	-f ./php8.1-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.2-fpm-apache \
	-t touch4it/php8:php8.2.29-fpm-apache \
	-t touch4it/php8:php8.2-fpm-apache \
	-f ./php8.2-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.3-fpm-apache \
	-t touch4it/php8:php8.3.28-fpm-apache \
	-t touch4it/php8:php8.3-fpm-apache \
	-t touch4it/php8:php8-fpm-apache \
	-f ./php8.3-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.4-fpm-apache \
	-t touch4it/php8:php8.4.15-fpm-apache \
	-t touch4it/php8:php8.4-fpm-apache \
	-f ./php8.4-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.5-fpm-apache \
	-t touch4it/php8:php8.5.0-fpm-apache \
	-t touch4it/php8:php8.5-fpm-apache \
	-t touch4it/php8:php8-fpm-apache \
	-t touch4it/php8:latest-fpm-apache \
	-f ./php8.5-fpm-apache/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

## Nginx + FPM

docker build ./php8.1-fpm-nginx \
	-t touch4it/php8:php8.1.33-fpm-nginx \
	-t touch4it/php8:php8.1-fpm-nginx \
	-f ./php8.1-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.2-fpm-nginx \
	-t touch4it/php8:php8.2.29-fpm-nginx \
	-t touch4it/php8:php8.2-fpm-nginx \
	-f ./php8.2-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.3-fpm-nginx \
	-t touch4it/php8:php8.3.28-fpm-nginx \
	-t touch4it/php8:php8.3-fpm-nginx \
	-f ./php8.3-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.4-fpm-nginx \
	-t touch4it/php8:php8.4.15-fpm-nginx \
	-t touch4it/php8:php8.4-fpm-nginx \
	-f ./php8.4-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.5-fpm-nginx \
	-t touch4it/php8:php8.5.0-fpm-nginx \
	-t touch4it/php8:php8.5-fpm-nginx \
	-t touch4it/php8:php8-fpm-nginx \
	-t touch4it/php8:latest-fpm-nginx \
	-t touch4it/php8:latest \
	-f ./php8.5-fpm-nginx/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Build development images

docker build ./php8.1-fpm-nginx-dev \
	-t touch4it/php8:php8.1.33-fpm-nginx-dev \
	-t touch4it/php8:php8.1-fpm-nginx-dev \
	-f ./php8.1-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.2-fpm-nginx-dev \
	-t touch4it/php8:php8.2.29-fpm-nginx-dev \
	-t touch4it/php8:php8.2-fpm-nginx-dev \
	-f ./php8.2-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.3-fpm-nginx-dev \
	-t touch4it/php8:php8.3.28-fpm-nginx-dev \
	-t touch4it/php8:php8.3-fpm-nginx-dev \
	-f ./php8.3-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.4-fpm-nginx-dev \
	-t touch4it/php8:php8.4.15-fpm-nginx-dev \
	-t touch4it/php8:php8.4-fpm-nginx-dev \
	-f ./php8.4-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php8.5-fpm-nginx-dev \
	-t touch4it/php8:php8.5.0-fpm-nginx-dev \
	-t touch4it/php8:php8.5-fpm-nginx-dev \
	-t touch4it/php8:php8-fpm-nginx-dev \
	-t touch4it/php8:latest-fpm-nginx-dev \
	-t touch4it/php8:latest-dev \
	-f ./php8.5-fpm-nginx-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Deploy production images

echo "Pushing PHP images"

docker image push touch4it/php8:php8.1.33-apache
docker image push touch4it/php8:php8.1-apache

docker image push touch4it/php8:php8.2.29-apache
docker image push touch4it/php8:php8.2-apache

docker image push touch4it/php8:php8.3.28-apache
docker image push touch4it/php8:php8.3-apache

docker image push touch4it/php8:php8.4.15-apache
docker image push touch4it/php8:php8.4-apache

docker image push touch4it/php8:php8.5.0-apache
docker image push touch4it/php8:php8.5-apache

docker image push touch4it/php8:php8-apache
docker image push touch4it/php8:latest-apache

docker image push touch4it/php8:php8.1.33-fpm-apache
docker image push touch4it/php8:php8.1-fpm-apache

docker image push touch4it/php8:php8.2.29-fpm-apache
docker image push touch4it/php8:php8.2-fpm-apache

docker image push touch4it/php8:php8.3.28-fpm-apache
docker image push touch4it/php8:php8.3-fpm-apache

docker image push touch4it/php8:php8.4.15-fpm-apache
docker image push touch4it/php8:php8.4-fpm-apache

docker image push touch4it/php8:php8.5.0-fpm-apache
docker image push touch4it/php8:php8.5-fpm-apache

docker image push touch4it/php8:php8-fpm-apache
docker image push touch4it/php8:latest-fpm-apache

docker image push touch4it/php8:php8.1.33-fpm-nginx
docker image push touch4it/php8:php8.1-fpm-nginx

docker image push touch4it/php8:php8.2.29-fpm-nginx
docker image push touch4it/php8:php8.2-fpm-nginx

docker image push touch4it/php8:php8.3.28-fpm-nginx
docker image push touch4it/php8:php8.3-fpm-nginx

docker image push touch4it/php8:php8.4.15-fpm-nginx
docker image push touch4it/php8:php8.4-fpm-nginx

docker image push touch4it/php8:php8.5.0-fpm-nginx
docker image push touch4it/php8:php8.5-fpm-nginx

docker image push touch4it/php8:php8-fpm-nginx
docker image push touch4it/php8:latest-fpm-nginx
docker image push touch4it/php8:latest

# Deploy development images

docker image push touch4it/php8:php8.1.33-fpm-nginx-dev
docker image push touch4it/php8:php8.1-fpm-nginx-dev

docker image push touch4it/php8:php8.2.29-fpm-nginx-dev
docker image push touch4it/php8:php8.2-fpm-nginx-dev

docker image push touch4it/php8:php8.3.28-fpm-nginx-dev
docker image push touch4it/php8:php8.3-fpm-nginx-dev

docker image push touch4it/php8:php8.4.15-fpm-nginx-dev
docker image push touch4it/php8:php8.4-fpm-nginx-dev

docker image push touch4it/php8:php8.5.0-fpm-nginx-dev
docker image push touch4it/php8:php8.5-fpm-nginx-dev

docker image push touch4it/php8:php8-fpm-nginx-dev
docker image push touch4it/php8:latest-fpm-nginx-dev
docker image push touch4it/php8:latest-dev
