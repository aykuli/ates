# frozen_string_literal: true

Doorkeeper.configure do
  orm :active_record

  resource_owner_authenticator do
    current_user || warden.authenticate!(scope: :user)
  end

  resource_owner_from_credentials do
    User.authenticate(params[:email], params[:password])
  end

  admin_authenticator do
    if current_user
      head :forbidden unless current_user.admin?
    else
      redirect_to sign_in_url
    end
  end

  access_token_expires_in 2.hours

  use_refresh_token

  allow_blank_redirect_uri true

  grant_flows %w[password authorization_code]

  skip_authorization do |_resource_owner, _client|
    true
  end

  default_scopes :public
end
