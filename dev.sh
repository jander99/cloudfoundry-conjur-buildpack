#!/bin/bash -e
function finish {
  echo 'Removing environment'
  echo '-----'
  docker-compose down -v
}
trap finish EXIT

. ./buildpack_vars.sh
. ./setup-conjur.sh

docker-compose run --rm -e CONJUR_CREDENTIALS_JSON="$CONJUR_CREDENTIALS_JSON" -e BUILDPACK_BUILD_DIR="$BUILDPACK_ROOT_DIR" tester bash
