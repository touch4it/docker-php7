#!/bin/bash

set -x

(cd ./php7/ || exit 1 ; sh build.sh)
(cd ./php8/ || exit 1 ; sh build.sh)
(cd ./drupal/ || exit 1 ; sh build.sh)
(cd ./symfony/ || exit 1 ; sh build.sh)
