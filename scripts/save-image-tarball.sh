#!/usr/bin/env bash

set -eu

./scripts/build-images.sh

echo
echo "caffeine: saving images to: caffeine-images.tar.gz"
docker save $(docker-compose config | awk '{if ($1 == "image:") print $2;}' ORS=" ") | gzip -c > caffeine-images.tar.gz

echo
echo "caffeine: done, images are saved in: caffeine-images.tar.gz"
