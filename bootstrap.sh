#!/usr/bin/env bash

set -eu

SERVICES="iam map-storage metabolic-ninja model model-storage warehouse design-storage id-mapper"

if [ $# != 1 ]; then

  echo "Please read the README"
  exit 1

elif [ "$1" = "check" ]; then

  [ "" != "$(which git)" ] && echo "git: ok"
  [ "" != "$(which docker)" ] && echo "docker: ok"
  [ "" != "$(which docker-compose)" ] && echo "docker-compose: ok"

  if [ -f "modeling-base/cplex_128.tar.gz" ]; then
    echo "modeling-base/cplex_128.tar.gz: ok"
  else
    echo "modeling-base/cplex_128.tar.gz: not found"
  fi

elif [ "$1" = "init" ]; then

  echo "Welcome! This init script will perform the following actions:"
  echo
  echo "  * clone git repositories for all required services"
  echo "  * build docker images"
  echo "  * create empty local databases"
  echo "  * create a demo user"
  echo
  echo "This may take a while (expect 10-15 minutes), depending on your bandwidth and processing power."
  echo "Please make sure './bootstrap.sh check' is all ok before starting."
  echo
  echo "Press enter to start, or ctrl+c to abort."
  read

  echo
  echo "caffeine (1/8): cloning git repositories"
  for SERVICE in $SERVICES; do
    if [ -d "${SERVICE}" ]; then
      rm -rfv ${SERVICE}
    fi
    git clone https://github.com/dd-decaf/${SERVICE}
  done

  echo
  echo "caffeine (2/8): pulling caffeine image"
  docker pull dddecaf/caffeine-local:latest

  echo
  echo "caffeine (3/8): building modeling base image"
  docker build -t gcr.io/dd-decaf-cfbf6/modeling-base:master modeling-base

  echo
  echo "caffeine (4/8): building services (this will take a few minutes)"
  docker-compose build

  echo
  echo "caffeine (5/8): generating iam keys"
  docker-compose run --rm iam ssh-keygen -t rsa -b 2048 -f keys/rsa -N ""

  echo
  echo "caffeine (6/8): creating databases"
  docker-compose down -v
  docker-compose up -d postgres
  ./iam/scripts/wait_for_postgres.sh
  docker-compose exec postgres psql -U postgres -c "create database iam;"
  docker-compose exec postgres psql -U postgres -c "create database maps;"
  docker-compose exec postgres psql -U postgres -c "create database metabolic_ninja;"
  docker-compose exec postgres psql -U postgres -c "create database model_storage;"
  docker-compose exec postgres psql -U postgres -c "create database warehouse;"
  docker-compose exec postgres psql -U postgres -c "create database designs;"
  docker-compose run --rm iam flask db upgrade
  docker-compose run --rm map-storage flask db upgrade
  docker-compose run --rm metabolic-ninja flask db upgrade
  docker-compose run --rm model-storage flask db upgrade
  docker-compose run --rm warehouse flask db upgrade
  docker-compose run --rm design-storage flask db upgrade

  echo
  echo "caffeine (7/8): populating id-mapper graph db"
  docker-compose up -d neo4j
  docker-compose exec neo4j neo4j-admin load --from=/dump/id-mapper.dump

  echo
  echo "caffeine (8/8): creating demo user"
  docker-compose run --rm -v "$(pwd):/bootstrap" iam python /bootstrap/generate-demo-users.py
  docker-compose stop

  echo
  echo "All done!"
  echo "You may authenticate on the platform with email 'demo[0-39]@demo' (where [0-39] indicates a number in the range 0 to 39) and password 'demo'."

fi
