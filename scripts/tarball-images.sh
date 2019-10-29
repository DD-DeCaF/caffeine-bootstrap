#!/usr/bin/env bash

set -eu

docker save $(docker-compose config | awk '{if ($1 == "image:") print $2;}' ORS=" ") | gzip -c > caffeine-images.tar.gz
