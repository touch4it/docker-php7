# symfony-docker
Docker image tailed to run symfony application

## What's here?

This repository is a source code for 4 docker images that allow relatively easly work with symfony php framework. Included images:

* jakubsacha/symfony-docker:php5
* jakubsacha/symfony-docker:php5-dev
* jakubsacha/symfony-docker:php7
* jakubsacha/symfony-docker:php7-dev

## What is the concept here?

You use php-dev images to develop by mounting your local directory into machine.
You use non-dev images to copy app code into image and then deploy your application to stage/live environments.

## What is the difference between php5 and php5-dev?

Non *dev* images are intended to be used in production. *Dev* images have xdebug installed additionally, so you can use it for debugging.

# Usage

### Development env with docker-compose.yml

You can you this docker-compose.yml file to develop:

```
www:
  build: jakubsacha/symfony-docker:php5-dev
  volumes:
    - ".:/var/www/html"
  ports:
    - "80:80"
```

### Adjust your syfony app kernel to write cache and logs to /tmp dir
```
    public function getCacheDir()
    {
        return sys_get_temp_dir().'/cache/'.$this->getEnvironment();
    }

    public function getLogDir()
    {
        return sys_get_temp_dir().'/logs/'.$this->getEnvironment();
    }
```

Use ```docker-compose up``` command to start your development environment.

### Output logs to stderr (optional)

You may want to adjust config_dev and config_prod to output logs to stderr (so they will be handled correctly by docker)
``
path:  "php://stderr"
``

# Build production image

You can build production ready image with dockerfile like this:

```
FROM jakubsacha/symfony-docker:php5
ADD . /var/www/html
# Add your application build steps here, for example:
# RUN ./var/www/html/web/bin/
RUN rm -rf /var/www/html/web/app_dev.php
```

# FAQ

## What are extensions enabled by default?
* apache mod_rewrite
* intl
* opcache
* pdo
* pdo_mysql
* xdebug (only in dev images)

## How do i install additional php extensions?
This work is based on official dockerhub php images. You can use docker-php-ext-install to add new extensions. More informations can be found [https://hub.docker.com/_/php/]

## Warning
Xdebug for PHP7 is in beta currently. If you have problems with php crashing, please use non-dev image.