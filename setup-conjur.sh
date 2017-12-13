#!/bin/bash -e

# get context
. ./docker_vars.sh

docker-compose up -d conjur

# wait for conjur
docker-compose run --rm tester bash ./wait_for_conjur.sh

# retrieve the API_KEY
. ./conjur_vars.sh

# set up conjur
docker-compose run --rm \
 -e CONJUR_APPLIANCE_URL=http://conjur \
 -e CONJUR_ACCOUNT=cucumber \
 -e CONJUR_AUTHN_API_KEY="$API_KEY" \
 -e CONJUR_AUTHN_LOGIN=admin \
 --entrypoint bash tester -c "
conjur policy load root $BUILDPACK_ROOT_DIR/ci/policy/root.yml
conjur variable values add conjur_single_line_secret_id 'a conjur secret on a single line'
conjur variable values add conjur_multi_line_secret_id 'a conjur secret
on multiple lines
'
"
