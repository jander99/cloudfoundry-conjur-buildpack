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

CREDS_PATH='.["cyberark-conjur"][0].credentials'
CREDS_FORMAT_OUTPUT=(
"CONJUR_ACCOUNT=\(.account)"
"CONJUR_AUTHN_API_KEY=\(.authn_api_key)"
"CONJUR_AUTHN_LOGIN=\(.authn_login)"
"CONJUR_APPLIANCE_URL=\(.appliance_url)"
)

function _export_var () {
  var=$1
  var_value=$2;
  var_value=$(echo "$var_value" | sed -e "s/'/'\\\''/g")
  echo "export $var='$var_value'"
}
export -f _export_var

# set cyberark-conjur credentials env vars
CRED_KEYS=$(printf "%s\n" "${CREDS_FORMAT_OUTPUT[@]}" | cut -d \= -f 2)
IFS=$'\n'; CRED_VARS=( $(printf "%s\n" "${CREDS_FORMAT_OUTPUT[@]}" | cut -d \= -f 1) )
IFS=$'\n'; CRED_VALUES=( $(echo $VCAP_SERVICES | jq --raw-output "$CREDS_PATH | \"$CRED_KEYS\"") )

. <(
for i in "${!CRED_VARS[@]}"; do
  _export_var ${CRED_VARS[$i]} ${CRED_VALUES[$i]}
done
)

# inject secrets into environment
pushd $BUILD_DIR
  # list of variables that summon will fetch (ignores variables that are already set)
  _summon_vars_list=$(./summon -p /bin/echo bash -c "comm -13 <(echo \"$(bash -c 'compgen -v | sort')\") <(compgen -v | sort)")
  # export variables from summon. except "set_summon_vars"
  source <(./summon -p ./summon-conjur bash <<EOL
echo "$_summon_vars_list" | while read line
do
  _export_var \$line "\${!line}"
done
EOL
)
popd

unset -f _export_var
