# frozen_string_literal: true

class BalancesUseCase
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

  # @param billing_data [Hash]
  #   @key cost                 [Float]
  #   @key user_public_uid  [String]
  #   @key event_time           [String]
  def deposited(billing_data)
    top_management = users_repository.find_by(admin: true)
    popug          = users_repository.find_by(public_uid: billing_data[:user_public_uid])

    top_management.update!(current: top_management.current + billing_data[:cost],time: billing_data[:event_time])
    popug.update!(current: popug.current - billing_data[:cost],time: billing_data[:event_time])
  end

  def withdrawn(billing_data)
    top_management = users_repository.find_by(admin: true)
    popug          = users_repository.find_by(public_uid: billing_data[:user_public_uid])

    top_management.update!(current: top_management.current - billing_data[:cost], time: billing_data[:event_time])
    popug.update!(current: popug.current + billing_data[:cost],time: billing_data[:event_time])
  end
end
