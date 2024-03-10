# frozen_string_literal: true

class TaskCostsUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] repository
  #   @return [TaskCostsRepository]
  resolve :task_costs_repository, as: :repository
  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] tasks_repository
  #   @return [TasksRepository]
  resolve :tasks_repository
  # @!attribute [r] producer
  #   @return [BillingsProducer]
  resolve :producer

  # @param task         [Task]
  def count_payments!(task)
    task_cost = repository.create_activity_costs!(task)

    events = charge_assigned_task!(task_cost)

    producer.produce_many_async(events)
  end

  # @param task_data            [Hash]
  #   @key task_public_uid      [String]
  #   @key assignee_public_uid  [String]
  #   @key task_title           [String]
  #   @key jira_id              [String]
  def reassign_payments!(task_data)
    task = tasks_repository.find_by(public_uid: task_data[:task_public_uid])
    task_cost = repository.find_by(task_id: task.id)

    events = charge_assigned_task!(task_cost)

    producer.produce_many_async(events)
  end

  # @param task_data            [Hash]
  #   @key task_public_uid      [String]
  #   @key assignee_public_uid  [String]
  #   @key task_title           [String]
  #   @key jira_id              [String]
  def done_payments!(task_data)
    task      = tasks_repository.find_by(public_uid: task_data[:task_public_uid])
    task_cost = repository.find_by(task_id: task.id)

    events = charge_assigned_task!(task_cost)

    producer.produce_many_async(events)
  end

  private


  # @param task_cost  [TaskCost]
  # @return           [Array<Event>]
  def charge_assigned_task!(task_cost)
    assignee        = task_cost.task.assignee
    top_management  = users_repository.find_by(admin: true)

    events = []

    ActiveRecord::Base.transaction do
      events << create_event!(assignee,       code: States::DEDUCTED, task_cost:, cost: task_cost.assign_cost)
      events << create_event!(top_management, code: States::EARNED,   task_cost:, cost: task_cost.assign_cost)
    end

    events
  end

  # @param task_cost [TaskCost]
  # @return          [Array<Event>]
  def charge_done_task(task_cost)
    assignee        = task_cost.task.assignee
    top_management  = users_repository.find_by(admin: true)

    events = []

    ActiveRecord::Base.transaction do
      create_event!(assignee,       code: States::EARNED,   task_cost:, cost: task_cost.solving_cost)
      create_event!(top_management, code: States::DEDUCTED, task_cost:, cost: task_cost.solving_cost)
    end

    events
  end

  # @param user     [User]
  # @param code     [String]
  #   @key user     [User]
  #   @key assignee [User]
  def create_event!(user, code:, task_cost:, cost:)
    user.events.create!(state: State.find_by(code:), task_cost_id: task_cost.id, cost:)
  end
end
