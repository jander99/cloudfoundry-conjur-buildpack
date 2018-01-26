#!/usr/bin/env bash
set +x

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

_conjur_BUILD_DIR=$1
_conjur_BIN_DIR="$_conjur_BUILD_DIR/bin"

# inject secrets into environment
pushd $_conjur_BUILD_DIR
  _conjur_tmp_script=$(BIN_DIR="$_conjur_BIN_DIR" ruby <<'EndOfRubyScript'
#!/usr/bin/ruby

require 'open3'
require 'yaml'

@creds_map = {
    :account => 'CONJUR_ACCOUNT',
    :authn_api_key => 'CONJUR_AUTHN_API_KEY',
    :authn_login => 'CONJUR_AUTHN_LOGIN',
    :appliance_url => 'CONJUR_APPLIANCE_URL'
}
@vcap_services = YAML::load(ENV['VCAP_SERVICES'].to_s)
@service_label = 'cyberark-conjur'

def generate_vcap_creds_hash
  if @vcap_services.empty?
    STDERR.puts('VCAP_SERVICES not found')
    exit(1)
  end

  vcap_service = @vcap_services[@service_label]
  if !vcap_service.is_a?(Array) || vcap_service.count == 0
    STDERR.puts("single-entry '#{@service_label}' array not found in VCAP_SERVICES")
    exit(1)
  end

  vcap_service = vcap_service[0]

  if !vcap_service.has_key? 'credentials'
    STDERR.puts("credentials not found under '#{@service_label}'[0] in VCAP_SERVICES")
    exit(1)
  end

  creds = vcap_service['credentials']
  valid_creds = @creds_map.all? do |key, _|
    creds.has_key? key.to_s
  end

  if !valid_creds
    STDERR.puts("malformed '#{@service_label}' credentials in VCAP_SERVICES")
    exit(1)
  end

  Hash[ @creds_map.map { |key, env_var_name| [ env_var_name, creds[key.to_s] ] } ]
end

def diff_hash(base, mod)
  mod.dup.delete_if { |k, v| base[k] == v }
end

def env_hash_from_commands(*commands)
  stdout, stderr, status = Open3.capture3(*commands)
  status.success? || (STDERR.puts(stdout + stderr); exit(status.exitstatus))

  YAML::load stdout
end

original_env_script = <<EOL
ruby -e "require 'yaml'; puts YAML::dump(ENV.to_h)";
EOL
summon_env_script = <<EOL
#{ENV['BIN_DIR']}/summon -p #{ENV['BIN_DIR']}/summon-conjur ruby -e "require 'yaml'; puts YAML::dump(ENV.to_h)";
EOL

vcap_creds_hash = generate_vcap_creds_hash
diff_hash(
    env_hash_from_commands({}, original_env_script),
    env_hash_from_commands(vcap_creds_hash, summon_env_script)
).each do |key, value|
  value = value.gsub("'", %q('"'"'))
  puts "export #{key}='#{value}'"
end

EndOfRubyScript
)
  # checks for error from ruby and passes it along
  [ $? -eq 0 ] || {
    _conjur_previous_exit=$?;
    echo "$_conjur_tmp_script";
    exit ${_conjur_previous_exit};
  }

  # evaluates the env_var exports
  eval "${_conjur_tmp_script}"
popd

# clean up
unset -f _conjur_tmp_script _conjur_previous_exit _conjur_BIN_DIR conjur_BUILD_DIR
