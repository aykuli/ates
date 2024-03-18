# frozen_string_literal: true

class UsersConsumer < ApplicationConsumer
  include Aux::Pluggable

  # @!attribute [r] use_case
  #   @return [UsersUseCase]
  resolve :users_use_case, as: :use_case

  def consume
    messages.each do |message|
      user_data = message.payload['data']
      case [message.payload['event_name'], message.payload['event_version']]
      when ['user.created', 1]
        use_case.create_from_oauth!(user_data)
      when ['user.updated', 1]
        use_case.update_from_oauth!(user_data)
      end
    end
  end
end
