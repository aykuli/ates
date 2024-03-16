# frozen_string_literal: true

class TasksUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] states_repository
  #   @return [StatesRepository]
  resolve :states_repository
  # @!attribute [r] repository
  #   @return [TasksRepository]
  resolve :tasks_repository, as: :repository
  # @!attribute [r] producer
  #   @return [BillingsProducer]
  resolve :billings_producer, as: :producer
  # @!method logger
  #   @return [Recorder::Agent]
  # resolve :logger

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  #   @key state            [String]
  def create!(task_data)
    repository.create!(
      public_uid: task_data[:task_public_uid],
      title: task_data[:task_title],
      jira_id: task_data[:jira_id],
      state: 'created'
    )

    # logger.info(message: 'Task was created',
    #             producer: "TasksUseCase.create",
    #             payload: task_data.to_s)
  end

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  #   @key state            [String]
  def charge_payments(task_data)
    task = repository.find_by(public_uid: task_data[:public_uid])
    task = create!(task_data) unless task

    user = users_repository.find_by(public_uid: task_data[:user_public_uid])
    unless user
      # logger.error(message: 'No user with such public_uuid while charge payments',
      #              producer: "TasksUseCase.charge_payments",
      #              payload: task_data.to_s)
      return nil
    end

    task.update!(
      assign_cost: rand(10..20),
      solving_cost: rand(20..40),
      user_public_uid: task_data[:user_public_uid],
      state: 'assigned')

    charge_task_assign_cost!(task, user)
  end

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  def recharge_payments(task_data)
    task = repository.find_by(public_uid: task_data[:task_public_uid])
    unless task
      # logger.error(message: 'No task with such public_uuid while recharge payments',
      #              producer: "TasksUseCase.recharge_payments",
      #              payload: task_data.to_s)
      return nil
    end

    user = users_repository.find_by(public_uid: task_data[:user_public_uid])
    unless user
      # logger.error(message: 'No user with such public_uuid while recharge payments',
      #              producer: "TasksUseCase.recharge_payments",
      #              payload: task_data.to_s)
      return nil
    end

    charge_task_assign_cost!(task,user)
  end

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  def pay_for_completed_task(task_data)
    task = repository.find_by(public_uid: task_data[:task_public_uid])

    unless task
      # logger.error(message: 'No task with such public_uuid while pay_for_completed_task',
      #              producer: "TasksUseCase.pay_for_completed_task",
      #              payload: task_data.to_s)
      return nil
    end
    user = users_repository.find_by(public_uid: task_data[:user_public_uid])

    charge_completed_task!(task, user)
  end

  private

  # @param task  [Task]
  def charge_task_assign_cost!(task,user)
    top_management = users_repository.find_by(admin: true)

    ActiveRecord::Base.transaction do
      create_event!(task, code: AccountStates::WITHDRAWN, cost: task.assign_cost, user:)
      create_event!(task, code: AccountStates::DEPOSITED, cost: task.assign_cost, user: top_management)
    end

    producer.produce_many_async(events)
  end

  # @param task [TaskCost]
  def charge_completed_task!(task,user)
    top_management = users_repository.find_by(admin: true)

    events = []
    ActiveRecord::Base.transaction do
      events << create_event!(task, code: AccountStates::WITHDRAWN, cost: task.solving_cost, user: top_management)
      events << create_event!(task, code: AccountStates::DEPOSITED, cost: task.solving_cost, user:)
    end

    producer.produce_many_async(events)
  end

  # @param task [Task]
  # @param code [String]
  # @param cost [Float]
  # @param user [User]
  def create_event!(task, code:, cost:, user:)
    task.events.create!(
      state: states_repository.find_by(code:),
      user_id: user.id,
      cost: cost
    )
  end
end
