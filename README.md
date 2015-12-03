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
