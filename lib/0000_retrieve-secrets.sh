#!/usr/bin/env bash

#export VCAP_SERVICES='
#{
#  "cyberark-conjur": [{
#    "credentials": {
#      "appliance_url": "https://conjur.myorg.com/",
#      "authn_api_key": "2389fh3hf9283niiejwfhjsb83ydbn23u",
#      "authn_login": "3F20D12E-A470-4B7B-8778-C8885769887F",
#      "account": "brokered-services"
#    }
#  }]
#}
#'

BUILD_DIR=$1
ESCAPE_SED='s/$/"/; s/=/="/; s/^/export /'

eval $(echo $VCAP_SERVICES | jq --raw-output '
."cyberark-conjur"[0].credentials |
"CONJUR_ACCOUNT=\(.account)
CONJUR_AUTHN_API_KEY=\(.authn_api_key)
CONJUR_AUTHN_LOGIN=\(.authn_login)
CONJUR_APPLIANCE_URL=\(.appliance_url)"
' | sed -e "$ESCAPE_SED")

pushd $BUILD_DIR
  eval $(./summon -p ./summon-conjur cat @SUMMONENVFILE | sed -e "$ESCAPE_SED")
popd
