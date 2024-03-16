# frozen_string_literal: true

class BalancesUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] tasks_repository
  #   @return [TasksRepository]
  resolve :tasks_repository
  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!method logger
  #   @return [Recorder::Agent]
  # resolve :logger

  # @param billing_data     [Hash]
  #   @key cost             [Float]
  #   @key user_public_uid  [String]
  #   @key event_time       [String]
  def deposited(billing_data)
    top_management = users_repository.find_by(admin: true)
    popug          = users_repository.find_by(public_uid: billing_data[:user_public_uid])

    top_management.balance.update!(
      current: top_management.current + billing_data[:cost],
      time: billing_data[:event_time]
    )
    popug.balance.update!(
      current: popug.current - billing_data[:cost],
      time: billing_data[:event_time]
    )
  end

  # @param billing_data    [Hash]
  #   @key cost            [Float]
  #   @key user_public_uid [String]
  #   @key event_time      [String]
  def withdrawn(billing_data)
    top_management = users_repository.find_by(admin: true)
    popug          = users_repository.find_by(public_uid: billing_data[:user_public_uid])

    top_management.balance.update!(
      current: top_management.current - billing_data[:cost],
      time: billing_data[:event_time]
    )
    popug.balance.update!(
      current: popug.current + billing_data[:cost],
      time: billing_data[:event_time]
    )
  end

  # @param task_costs_data   [Hash]
  #   @key task_public_uid   [String]
  #   @key task_assign_cost  [Float]
  #   @key task_solving_cost [Float]
  def save_task_costs(task_costs_data)
    task = tasks_repository.find_by(public_uid: task_costs_data[:task_public_uid])
    return unless task

    # logger.info(message: 'Task was not found to save its assign and solving costs',
    #             producer: "BalancesUseCase.save_task_costs",
    #             payload: task_costs_data.to_s) unless task

    task.update!(
      assign_cost: task_costs_data[:task_assign_cost],
      solving_cost: task_costs_data[:task_solving_cost]
    )
  end
end
