# frozen_string_literal: true

class TasksUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] repository
  #   @return [TasksRepository]
  resolve :tasks_repository, as: :repository

  # @param data            [Hash]
  #   @key task_public_uid      [String]
  #   @key assignee_public_uid  [String]
  #   @key task_title           [String]
  #   @key jira_id              [String]
  # @return [Task]
  def create_as_consumer!(data)
    assignee = users_repository.find_by(public_uid: data[:assignee_public_uid])

    repository.create!(
      public_uid: data[:task_public_uid],
      assignee_id: assignee.id,
      title: data[:task_title],
      jira_id:data[:task_title]    )
  end
end
