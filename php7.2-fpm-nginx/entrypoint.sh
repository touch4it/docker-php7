#!/usr/bin/env bash

php-fpm &
crond -L /var/log/cron/cron.log -b &
nginx -g "daemon off;"
