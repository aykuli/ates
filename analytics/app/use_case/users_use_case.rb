# frozen_string_literal: true

class UsersUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] done_tasks_repository
  #   @return [DoneTasksRepository]
  resolve :done_tasks_repository
  # @!attribute [r] balances_repository
  #   @return [BalancesRepository]
  resolve :balances_repository

  # @param user_data [Hash]
  def create_user(user_data)
    user = users_repository.create!(**user_data)
    return unless user

    user.update!(**user_data)
  end

  # @param user_data [Hash]
  def update_user(user_data)
    user = users_repository.find_by(public_uid: user_data.delete('public_uid'))
    return unless user

    user.update!(**user_data)
  end
end
