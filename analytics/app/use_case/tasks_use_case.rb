# frozen_string_literal: true

class TasksUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] repository
  #   @return [TasksRepository]
  resolve :tasks_repository, as: :repository
  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!method logger
  #   @return [Recorder::Agent]
  # resolve :logger

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  #   @key state            [String]
  def create(task_data)
    task = repository.find_by(public_uid: task_data[:public_uid])

    return if task

    repository.create!(
      public_uid: task_data[:public_uid],
      title: task_data[:title],
      jira_id: task_data[:jira_id],
      user_public_uid: task_data[:user_public_uid],
      state: 'task.created'
    )

    # logger.info(message: 'Task was created',
    #             producer: "TasksUseCase.create",
    #             payload: task_data.to_s) unless task
  end

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  #   @key state            [String]
  def update(task_data)
    task = repository.find_by(public_uid: task_data[:public_uid])
    task ||= create!(task_data)

    user = users_repository.find_by(public_uid: task_data[:user_public_uid])
    unless user
      # logger.error(message: 'No user with such public_uuid while charge payments',
      #              producer: "TasksUseCase.charge_payments",
      #              payload: task_data.to_s)
      return nil
    end

    task.update!(
      public_uid: task_data[:public_uid],
      assign_cost: task_data[:assign_cost],
      solving_cost: task_data[:solving_cost],
      state: task_data[:state]
    )

    # logger.info(message: 'Task was updated',
    #             producer: "TasksUseCase.update",
    #             payload: task_data.to_s)
  end
end
