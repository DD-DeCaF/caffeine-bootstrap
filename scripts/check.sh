#!/usr/bin/env sh

set -eu

which bash > /dev/null && echo "bash: ok" ||  echo "bash: no"
which git > /dev/null && echo "git: ok" ||  echo "git: no"
which docker > /dev/null && echo "docker: ok" ||  echo "docker: no"
which docker-compose > /dev/null && echo "docker-compose: ok" || \
    echo "docker-compose: no"
