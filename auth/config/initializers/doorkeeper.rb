# frozen_string_literal: true

Doorkeeper.configure do
  orm :active_record

  resource_owner_from_credentials do
    User.authenticate(params[:email], params[:password])
  end

  access_token_expires_in 2.hours

  use_refresh_token

  allow_blank_redirect_uri true

  grant_flows %w[password]

  skip_authorization do |_resource_owner, _client|
    true
  end

end
