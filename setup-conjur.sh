#!/bin/bash -e

# get context
. ./docker_vars.sh

docker-compose up -d conjur

# wait for conjur
docker-compose run --rm tester bash ./wait_for_conjur.sh
