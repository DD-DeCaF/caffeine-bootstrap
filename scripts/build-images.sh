#!/usr/bin/env bash

set -eu

SERVICES="iam map-storage metabolic-ninja simulations model-storage warehouse design-storage id-mapper metanetx"

echo
echo "caffeine: cloning git repositories"
for SERVICE in $SERVICES; do
  if [ -d "${SERVICE}" ]; then
    rm -rfv ${SERVICE}
  fi
  git clone https://github.com/dd-decaf/${SERVICE}
done

echo
echo "caffeine: pulling caffeine image"
docker pull dddecaf/caffeine-vue-demo:latest

echo
echo "caffeine: building modeling base image"
docker build -t gcr.io/dd-decaf-cfbf6/modeling-base:master modeling-base

echo
echo "caffeine: building services (this will take a few minutes)"
docker-compose build
