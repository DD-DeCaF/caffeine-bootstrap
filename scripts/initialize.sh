#!/usr/bin/env bash

set -eu

echo
echo "caffeine: generating iam keys"
docker-compose run --rm iam ssh-keygen -t rsa -b 2048 -f keys/rsa -N ""

echo
echo "caffeine: creating databases"
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
echo "caffeine: populating id-mapper graph db"
docker-compose up -d neo4j
docker-compose exec neo4j neo4j-admin load --from=/dump/id-mapper.dump

echo
echo "caffeine: creating demo users"
docker-compose run --rm -v "$(pwd)/scripts:/bootstrap" iam python /bootstrap/generate-demo-users.py
docker-compose stop
