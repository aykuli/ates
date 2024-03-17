# frozen_string_literal: true

# Example consumer that prints messages payloads
class UsersConsumer < ApplicationConsumer
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository

  def consume
    messages.each do |message|
      user_data = message.payload['data']

      case message.payload['event_name']
      when 'user.created'
        user = users_repository.create!(**user_data)
        next unless user

        user.update!(**user_data)
      when 'user.updated'
        user = users_repository.find_by(public_uid: user_data.delete('public_uid'))
        next unless user

        user.update!(**user_data)
      end
    end
  end
end
