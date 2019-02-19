#!/usr/bin/env bash

set -eu

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
  echo "caffeine (1/7): cloning git repositories"
  SERVICES="iam map-storage metabolic-ninja model model-storage warehouse design-storage"
  for SERVICE in $SERVICES; do
    git clone https://github.com/dd-decaf/${SERVICE}
  done

  echo
  echo "caffeine (2/7): pulling caffeine image"
  docker pull dddecaf/caffeine-local:latest

  echo
  echo "caffeine (3/7): building modeling base image"
  docker build -t gcr.io/dd-decaf-cfbf6/modeling-base:master modeling-base

  echo
  echo "caffeine (4/7): building services (this will take a few minutes)"
  docker-compose build

  echo
  echo "caffeine (5/7): generating iam keys"
  docker-compose run --rm iam ssh-keygen -t rsa -b 2048 -f keys/rsa -N ""

  echo
  echo "caffeine (6/7): creating databases"
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
  echo "caffeine (7/7): creating demo user"
  docker-compose run --rm iam python -c "from iam.models import User, db; from iam.app import app, init_app; init_app(app, db); app.app_context().push(); user = User(email='demo@demo'); user.set_password('demo'); db.session.add(user); db.session.commit()"
  docker-compose stop

  echo
  echo "All done!"
  echo "You may authenticate on the platform with email 'demo@demo' and password 'demo'."

fi
