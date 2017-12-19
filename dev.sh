#!/bin/bash -e
function finish {
  echo 'Removing environment'
  echo '-----'
  docker-compose down -v
}
trap finish EXIT

. ./buildpack_vars.sh
. ./setup-conjur.sh

# run tests against buildpack source
docker-compose run --rm -e BUILDPACK_BUILD_DIR="$BUILDPACK_ROOT_DIR" tester bash
