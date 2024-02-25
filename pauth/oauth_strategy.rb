# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Ates < OmniAuth::Strategies::OAuth2
      option :name, :ates

      option :client_options, {
        site: Settings.oauth.host
      }

      info do
        {
          public_uid: raw_info['public_uid'],
          email: raw_info['email'],
          admin: raw_info['admin']
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/users/current').parsed
      end
    end
  end
end
