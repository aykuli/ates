# frozen_string_literal: true

class UsersUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!method logger
  #   @return [Recorder::Agent]
  # resolve :logger

  # @param user_data [Hash]
  def create(user_data)
    user = users_repository.create!(**user_data)
    return unless user

    user.update!(**user_data)

    # logger.info(message: 'User was created',
    #             producer: "UsersUseCase.create",
    #             payload: user_data.to_s)
  end

  # @param user_data [Hash]
  def update(user_data)
    user = users_repository.find_by(public_uid: user_data.delete('public_uid'))
    return unless user

    user.update!(**user_data)

    # logger.info(message: 'User was updated',
    #             producer: "UsersUseCase.update",
    #             payload: user_data.to_s)
  end
end
