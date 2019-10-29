#!/usr/bin/env bash

set -eu

[ "" != "$(which git)" ] && echo "git: ok"
[ "" != "$(which docker)" ] && echo "docker: ok"
[ "" != "$(which docker-compose)" ] && echo "docker-compose: ok"

if [ -f "modeling-base/cplex_128.tar.gz" ]; then
  echo "modeling-base/cplex_128.tar.gz: ok"
else
  echo "modeling-base/cplex_128.tar.gz: not found"
fi
