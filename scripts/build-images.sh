#!/usr/bin/env bash

set -eu

SERVICES="iam map-storage metabolic-ninja simulations model-storage warehouse design-storage id-mapper metanetx"

function get_default_branch {
 basename $(cat .git/refs/remotes/origin/HEAD | awk '{ print $2 }')
}

echo
echo "caffeine: cloning git repositories"
for SERVICE in $SERVICES; do
  if [ -d "${SERVICE}" ]; then
    cd "${SERVICE}"
    branch=$(get_default_branch)
    git checkout ${branch}
    git pull origin ${branch}
    cd ..
  else
    git clone --depth 3 https://github.com/dd-decaf/${SERVICE}
  fi
done

echo
echo "caffeine: pulling base images"
docker pull dddecaf/wsgi-base:alpine
docker pull dddecaf/wsgi-base:alpine-compiler
docker pull dddecaf/wsgi-base:debian
docker pull dddecaf/postgres-base:master
docker pull dddecaf/postgres-base:compiler

echo
echo "caffeine: pulling caffeine image"
docker pull dddecaf/caffeine-vue-demo:latest

echo
echo "caffeine: building local modeling base image"
docker build --tag gcr.io/dd-decaf-cfbf6/modeling-base:master modeling-base

echo
echo "caffeine: building services (this will take a few minutes)"
docker-compose build --pull --parallel
