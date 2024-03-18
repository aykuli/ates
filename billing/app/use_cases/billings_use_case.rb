# frozen_string_literal: true

class BillingsUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] states_repository
  #   @return [StatesRepository]
  resolve :states_repository
  # @!attribute [r] tasks_repository
  #   @return [TasksRepository]
  resolve :tasks_repository
  # @!attribute [r] producer
  #   @return [BillingsProducer]
  resolve :billings_producer, as: :producer
  # @!method logger
  #   @return [Recorder::Agent]
  resolve :logger

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  #   @key state            [String]
  #   @key updated_at       [String]
  def charge_payments(task_data)
    task = tasks_repository.find_by(public_uid: task_data[:public_uid])
    task ||= tasks_repository.create_as_consumer!(task_data)

    user = users_repository.find_by(public_uid: task_data[:user_public_uid])
    unless user
      logger.error(message: 'No user with such public_uuid while charge payments',
                   producer: "BillingsUseCase.charge_payments",
                   payload: task_data.to_s)
      return nil
    end

    return unless task.updated_at != task_data[:updated_at]

    task.update!(
      assign_cost: rand(10..20),
      solving_cost: rand(20..40),
      user_public_uid: task_data[:user_public_uid],
      updated_at: task_data[:updated_at],
      state: 'assigned'
    )

    # share with analytics about task costs
    producer.produce_async('task_costs_counted', task)

    assign_cost_charge!(task, user)
  end

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  def recharge_payments(task_data)
    task = tasks_repository.find_by(public_uid: task_data[:public_uid])
    unless task
      logger.error(message: 'No task with such public_uuid while recharge payments',
                   producer: "BillingsUseCase.recharge_payments",
                   payload: task_data.to_s)
      return nil
    end

    user = users_repository.find_by(public_uid: task_data[:user_public_uid])
    unless user
      logger.error(message: 'No user with such public_uuid while recharge payments',
                   producer: "BillingsUseCase.recharge_payments",
                   payload: task_data.to_s)
      return nil
    end

    reassign_cost_charge!(task, user) if task.updated_at != task_data[:updated_at]
  end

  # @param task_data        [Hash]
  #   @key public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  def pay_for_completed_task(task_data)
    task = tasks_repository.find_by(public_uid: task_data[:public_uid])
    unless task
      logger.error(message: 'No task with such public_uuid while pay_for_completed_task',
                   producer: "BillingsUseCase.pay_for_completed_task",
                   payload: task_data.to_s)
      return nil
    end

    user = users_repository.find_by(public_uid: task_data[:user_public_uid])

    return unless task.updated_at != task_data[:updated_at]

    task.update!(
      user_public_uid: task_data[:user_public_uid],
      updated_at: task_data[:updated_at],
      state: 'completed'
    )

    charge_completed_task!(task, user)
  end

  private

  # @param task  [Task]
  # @param user  [User]
  def assign_cost_charge!(task, user)
    top_management = users_repository.find_by(admin: true)

    billing_events = []
    ActiveRecord::Base.transaction do
      billing_events << create_event!(user, code: AccountStates::WITHDRAWN, cost: task.assign_cost, task:)
      billing_events << create_event!(top_management, code: AccountStates::DEPOSITED, cost: task.assign_cost, task:)
    end

    producer.produce_many_async(billing_events)
  end

  # @param task  [Task]
  # @param user  [User]
  def reassign_cost_charge!(task, user)
    top_management = users_repository.find_by(admin: true)

    billing_events = []
    ActiveRecord::Base.transaction do
      billing_events << create_event!(user, code: AccountStates::WITHDRAWN, cost: task.assign_cost, task:)
      billing_events << create_event!(top_management, code: AccountStates::DEPOSITED, cost: task.assign_cost, task:)
    end

    producer.produce_many_async(billing_events)
  end

  # @param task [TaskCost]
  def charge_completed_task!(task, user)
    top_management = users_repository.find_by(admin: true)

    billing_events = []
    ActiveRecord::Base.transaction do
      billing_events << create_event!(top_management, code: AccountStates::WITHDRAWN, cost: task.solving_cost, task:)
      billing_events << create_event!(user, code: AccountStates::DEPOSITED, cost: task.solving_cost, task:)
    end

    producer.produce_many_async(billing_events)
  end

  # @param user [User]
  # @param code [String]
  # @param task [Task]
  # @param cost [Float]
  def create_event!(user, code:, task:, cost:)
    user.billing_events.create!(
      state: states_repository.find_by(code:),
      task_id: task.id,
      cost:
    )
  end
end
