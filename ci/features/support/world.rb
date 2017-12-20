module BuildpackWorld

  def load_root_policy policy
    load_policy 'root', policy
  end

  def load_policy id, policy
    conjur_api.load_policy id, policy, method: Conjur::API::POLICY_METHOD_PUT
  end

  def make_full_id *tokens
    ([Conjur.configuration.account] + tokens).join(':')
  end

  def conjur_api
    login_as_role 'admin', admin_api_key unless @conjur_api
    @conjur_api
  end

  def admin_api_key
    @admin_api_key ||= Conjur::API.login 'admin', admin_password
  end

  def admin_password
    'admin'
  end

  def login_as_role login, api_key = nil
    api_key = admin_api_key if login == 'admin'
    unless api_key
      role = if login.index('/')
               login.split('/', 2).join(':')
             else
               [ 'user', login ].join(':')
             end
      api_key = Conjur::API.new_from_key('admin', admin_api_key).role(make_full_id(role)).rotate_api_key
    end
    @conjur_api = Conjur::API.new_from_key login, api_key
  end
end

World(BuildpackWorld)
