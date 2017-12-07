#!/bin/bash -e

function finish {
  echo 'Removing environment'
  echo '-----'
  docker-compose down -v
}
trap finish EXIT

# sets up conjur and retrieves credentials
. ./setup-conjur.sh

# unpack latest build of buildpack
docker-compose run --rm tester bash ./unpack.sh

# run tests against latest build of buildpack
docker-compose run --rm \
 -e CONJUR_CREDENTIALS_JSON="$CONJUR_CREDENTIALS_JSON" \
 -w "$BUILDPACK_ROOT_DIR/ci" \
 tester cucumber --format pretty --format junit --out ./features/reports
