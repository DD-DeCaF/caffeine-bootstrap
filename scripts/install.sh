#!/usr/bin/env bash

set -eu

./scripts/build-images.sh
./scripts/initialize.sh

echo
echo "caffeine: installation complete"
