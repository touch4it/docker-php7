#!/usr/bin/env bash

php-fpm &
crond -s /etc/cron.d -f &
nginx -g "daemon off;"
