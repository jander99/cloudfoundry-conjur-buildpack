#!/bin/bash -e

. ./docker_vars.sh

API_KEY=$(docker-compose exec -T conjur rails r "print Credentials['cucumber:user:admin'].api_key")

CONJUR_CREDENTIALS_JSON=$(cat << EOL
{
  "appliance_url": "http://conjur",
  "authn_api_key": "$API_KEY",
  "authn_login": "admin",
  "account": "cucumber"
}
EOL
)
