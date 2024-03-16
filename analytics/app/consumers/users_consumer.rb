# frozen_string_literal: true

class UsersConsumer < ApplicationConsumer
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_use_case
  #   @return [UsersUseCase]
  resolve :users_use_case

  def consume
    messages.each do |message|
      user_data = message.payload['data']

      case [message.payload['event_name'], message.payload['event_version']]
      when ['user.created', 1]
        users_use_case.create(user_data)

      when ['user.updated', 1]
        users_use_case.update(user_data)
      end
    end
  end
end
