#!/bin/bash

# Build production images

echo "Building Yii images"

docker buildx build ./php7.3-fpm-nginx-yii2 \
	-t touch4it/yii2-php-fpm-nginx:7.3 \
	-f ./php7.3-fpm-nginx-yii2/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-nginx-yii2 \
	-t touch4it/yii2-php-fpm-nginx:latest \
	-t touch4it/yii2-php-fpm-nginx:7.4 \
	-f ./php7.4-fpm-nginx-yii2/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

# Build development images

docker buildx build ./php7.3-fpm-nginx-yii2-dev \
	-t touch4it/yii2-php-fpm-nginx:7.3-dev \
	-f ./php7.3-fpm-nginx-yii2-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1

docker buildx build ./php7.4-fpm-nginx-yii2-dev \
	-t touch4it/yii2-php-fpm-nginx:7.4-dev \
	-f ./php7.4-fpm-nginx-yii2-dev/Dockerfile \
	--platform linux/amd64,linux/arm64 \
	--push \
	|| exit 1
