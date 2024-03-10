# frozen_string_literal: true

class UsersUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository, as: :repository

  # @param user_data    [Hash]
  #   @key public_uid   [String]
  #   @key email        [String]
  #   @key admin        [Boolean]
  def create_from_oauth!(user_data) = users_repository.create!(**user_data)

  # @param user_data    [Hash]
  #   @key public_uid   [String]
  #   @key email        [String]
  #   @key admin        [Boolean]
  def update_from_oauth!(user_data)
    user = users_repository.find_by(public_uid: user_data.delete('public_uid'))
    return unless user

    user.update!(**user_data)
  end
end
