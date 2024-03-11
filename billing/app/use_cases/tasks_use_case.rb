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
  resolve :producer


  # @param task_data            [Hash]
  #   @key task_public_uid      [String]
  #   @key assignee_public_uid  [String]
  #   @key task_title           [String]
  #   @key jira_id              [String]
  # @return [Task]
  def assign_payments(task_data)
    assignee = users_repository.find_by(public_uid: task_data[:assignee_public_uid])

    return unless assignee # todo write log

    task =  repository.create!(
      public_uid: task_data[:task_public_uid],
      assignee_id: assignee.id,
      title: task_data[:task_title],
      jira_id:task_data[:task_title],
    assign_cost: rand(10..20), solving_cost: rand(20..40))

    charge_assigned_task!(task)

    producer.produce_async(BillingsProducer::MANAGEMENT_EARN_EVENT, {
      cost: task.assign_cost,
      assignee_public_uid: task_data[:assignee_public_uid]
    })

  end


  # @param task_data            [Hash]
  #   @key task_public_uid      [String]
  #   @key assignee_public_uid  [String]
  #   @key task_title           [String]
  #   @key jira_id              [String]
  def reassign_payments(task_data)
    task = repository.find_by(public_uid: task_data[:task_public_uid])

    charge_assigned_task!(task)

    producer.produce_async(BillingsProducer::MANAGEMENT_EARN_EVENT, {
      cost: task.assign_cost,
      assignee_public_uid: task.assignee.public_uid,
    })
  end


  # @param task_data            [Hash]
  #   @key task_public_uid      [String]
  #   @key assignee_public_uid  [String]
  #   @key task_title           [String]
  #   @key jira_id              [String]
  def pay_done_task(task_data)
    task = repository.find_by(public_uid: task_data[:task_public_uid])

    charge_done_task!(task)


    producer.produce_async(BillingsProducer::MANAGEMENT_DEDUCTED_EVENT, {
      cost: task.solving_cost,
      assignee_public_uid: task.assignee.public_uid
    })
  end


  private


  # @param task  [Task]
  def charge_assigned_task!(task)
    top_management  = users_repository.find_by(admin: true)


    ActiveRecord::Base.transaction do
      create_event!(task.assignee,       code: States::DEDUCTED, task:, cost: task.assign_cost)
      create_event!(top_management, code: States::EARNED,   task:, cost: task.assign_cost)
    end
  end


  # @param task [TaskCost]
  def charge_done_task!(task)
    top_management  = users_repository.find_by(admin: true)

    ActiveRecord::Base.transaction do
      create_event!(task.assignee,  code: States::EARNED,   task:, cost: task.solving_cost)
      create_event!(top_management, code: States::DEDUCTED, task:, cost: task.solving_cost)
    end
  end

  # @param task       [Task]
  # @param state_code [String]
  #   @key user       [User]
  #   @key assignee   [User]
  def create_event(task, state_code, user:, assignee: nil)
    task.events.create!(
      state: states_repository.find_by(code: state_code),
      user_id: user.id,
      assignee_id: assignee&.id
    )
  end
end
