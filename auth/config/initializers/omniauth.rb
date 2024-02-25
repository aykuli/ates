# frozen_string_literal: true

require File.expand_path('lib/omniauth/strategies/aynur', Rails.root)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :aynur, ENV.fetch('OAUTH_ID', nil), ENV.fetch('OAUTH_SECRET', nil)
end
