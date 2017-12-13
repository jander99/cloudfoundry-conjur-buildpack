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

CREDS_PATH='.["cyberark-conjur"][0].credentials'
CREDS_FORMAT_OUTPUT=$(echo "
CONJUR_ACCOUNT=\(.account)
CONJUR_AUTHN_API_KEY=\(.authn_api_key)
CONJUR_AUTHN_LOGIN=\(.authn_login)
CONJUR_APPLIANCE_URL=\(.appliance_url)
" | grep '.*\S.*')

eval $(echo $VCAP_SERVICES | jq --raw-output "$CREDS_PATH | \"$CREDS_FORMAT_OUTPUT\"" | sed -e "$ESCAPE_SED")

pushd $BUILD_DIR
# list of variables that summon will fetch (ignores variables that are already set)
  _summon_vars_list=$(./summon -p /bin/echo bash -c "comm -13 <(echo \"$(bash -c 'compgen -v | sort')\") <(compgen -v | sort)")
# export variables from summon. except "set_summon_vars"
  _set_summon_vars=$(env _summon_vars_list="$_summon_vars_list" ./summon -p ./summon-conjur bash <<'EOL'
echo "$_summon_vars_list" | while read line
do
  var=$line;
  var_value=$(eval "echo \"\$$var\"");

  if [ ! $(echo "$var_value" | wc -l) -eq 1 ]
  then
    var_value=$(echo "$var_value" | jq . -R -s);
  else
    var_value="\"$var_value\""
  fi

  echo "$var"'=$(cat <<'"'EOV'"
  echo "$var_value"
  echo 'EOV'
  echo ')'

  echo "export $var=\$(echo \"\$$var\" | jq -r .)"
done
EOL
)
  eval "$_set_summon_vars"
popd
