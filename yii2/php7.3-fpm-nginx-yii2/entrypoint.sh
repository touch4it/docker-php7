#!/usr/bin/env bash

if [ -n "${GITHUB_API_TOKEN}" ]
then
  echo "configuring github token"
  composer config -g github-oauth.github.com ${GITHUB_API_TOKEN}
fi

echo "installing composer packages"

composer install

echo "launching .."

php-fpm &
crond -s /etc/cron.d -f &
nginx -g "daemon off;"
