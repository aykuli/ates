# frozen_string_literal: true

class TasksUseCase

  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] repository
  #   @return [TasksRepository]
  resolve :tasks_repository, as: :repository
  # @!method logger
  #   @return [Recorder::Agent]
  resolve :logger

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
      task_jira_id: task_data[:task_jira_id],
      state: 'created'
    )

    logger.info(message: 'Task was created',
                producer: "TasksUseCase.create",
                payload: task_data.to_s)
  end


  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  #   @key state            [String]
  def update(task_data)
    task = repository.find_by(public_uid: task_data[:public_uid])
    task = create!(task_data) unless task

    task.update!(
      public_uid: task_data[:task_public_uid],
      assign_cost: task_data[:assign_cost],
      solving_cost: task_data[:solving_cost],
      state: task_data[:state]
    )

    logger.info(message: 'Task was updated',
                producer: "TasksUseCase.update",
                payload: task_data.to_s)
  end
end
