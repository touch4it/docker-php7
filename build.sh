#!/bin/bash

set -x

(cd ./php8/ || exit 1 ; sh build.sh)
(cd ./drupal/ || exit 1 ; sh build.sh)
