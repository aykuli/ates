# frozen_string_literal: true

class UsersConsumer < ApplicationConsumer
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository

  def consume
    messages.each do |message|
      user_data = message.payload['data']

      case [message.payload['event_name'], message.payload['event_version']]
      when ['user.created', 1]
        user = users_repository.create!(**user_data)
        next unless user

        user.update!(**user_data)
      when ['user.updated', 1]
        user = users_repository.find_by(public_uid: user_data.delete('public_uid'))
        next unless user

        user.update!(**user_data)
      end
    end
  end
end
