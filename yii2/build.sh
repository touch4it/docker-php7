#!/bin/bash

# Build production images

echo "Building Yii images"

docker build ./php7.3-fpm-nginx-yii2 \
	-t touch4it/yii2-php-fpm-nginx:7.3 \
	-f ./php7.3-fpm-nginx-yii2/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php7.4-fpm-nginx-yii2 \
	-t touch4it/yii2-php-fpm-nginx:latest \
	-t touch4it/yii2-php-fpm-nginx:7.4 \
	-f ./php7.4-fpm-nginx-yii2/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Build development images

docker build ./php7.3-fpm-nginx-yii2-dev \
	-t touch4it/yii2-php-fpm-nginx:7.3-dev \
	-f ./php7.3-fpm-nginx-yii2-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

docker build ./php7.4-fpm-nginx-yii2-dev \
	-t touch4it/yii2-php-fpm-nginx:7.4-dev \
	-f ./php7.4-fpm-nginx-yii2-dev/Dockerfile \
	--platform linux/amd64 \
	|| exit 1

# Push production images

echo "Pushing Yii images"

docker push touch4it/yii2-php-fpm-nginx:latest
docker push touch4it/yii2-php-fpm-nginx:7.3
docker push touch4it/yii2-php-fpm-nginx:7.4

# Push dev images

docker push touch4it/yii2-php-fpm-nginx:7.3-dev
docker push touch4it/yii2-php-fpm-nginx:7.4-dev
