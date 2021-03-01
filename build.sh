#!/bin/bash

set -x

(cd ./php7/ || exit ; sh build.sh)
(cd ./php8/ || exit ; sh build.sh)
(cd ./drupal/ || exit ; sh build.sh)
(cd ./yii2/ || exit ; sh build.sh)
(cd ./symfony/ || exit ; sh build.sh)
