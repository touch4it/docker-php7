# symfony-docker
Docker image tailed to run symfony application

# Installation

1. Adjust your app kernel to write cache and logs to /tmp dir
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

2. Output logs to stderr (optional)

You may want to adjust config_dev and config_prod to output logs to stderr (so they will be handled correctly by docker)
``
path:  "php://stderr"
``

3. Docker composer

You can you this docker-compose.yml file to develop:

```
www:
  build: jakubsacha/symfony-docker:www5-dev
  volumes:
    - ".:/var/www/html"
  ports:
    - "80:80"
```

# Build production image

You can build production image with

```
FROM jakubsacha/symfony-docker:www5
ADD . /var/www/html
```

