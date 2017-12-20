#!/bin/bash -e

. ./docker_vars.sh

docker-compose build
docker-compose run --rm tester ./build.sh
