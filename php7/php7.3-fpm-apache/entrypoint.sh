#!/usr/bin/env bash

php-fpm &
cron -f &
apache2-foreground
