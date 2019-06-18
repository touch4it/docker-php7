#!/usr/bin/env bash

php-fpm &
crond -s /etc/cron.d -L /var/log/cron/cron.log -b &
nginx -g "daemon off;"
