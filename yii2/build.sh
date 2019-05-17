#!/bin/bash

# Build production images

docker build --no-cache ./yii2/php7.1-fpm-nginx-yii2 \
	-t touch4it/yii2-php-fpm-nginx:latest \
	-t touch4it/yii2-php-fpm-nginx:7.1 \
	-f ./yii2/php7.1-fpm-nginx-yii2/Dockerfile

docker build --no-cache ./yii2/php7.2-fpm-nginx-yii2 \
	-t touch4it/yii2-php-fpm-nginx:7.2 \
	-f ./yii2/php7.2-fpm-nginx-yii2/Dockerfile

# Build development images

docker build --no-cache ./yii2/php7.1-fpm-nginx-yii2-dev \
	-t touch4it/yii2-php-fpm-nginx:7.1-dev \
	-f ./yii2/php7.1-fpm-nginx-yii2-dev/Dockerfile

docker build --no-cache ./yii2/php7.2-fpm-nginx-yii2-dev \
	-t touch4it/yii2-php-fpm-nginx:7.2-dev \
	-f ./yii2/php7.2-fpm-nginx-yii2-dev/Dockerfile

# Deploy production images

docker push touch4it/yii2-php-fpm-nginx:latest
docker push touch4it/yii2-php-fpm-nginx:7.1
docker push touch4it/yii2-php-fpm-nginx:7.2

# Deploy dev images

docker push touch4it/yii2-php-fpm-nginx:7.1-dev
docker push touch4it/yii2-php-fpm-nginx:7.2-dev
