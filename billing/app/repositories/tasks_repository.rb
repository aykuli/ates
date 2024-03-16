# frozen_string_literal: true

class TasksRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method find_by!(attributes)
  #   @param attributes [Hash]
  #   @return           [Task]
  delegate :find_by, to: :gateway

  # @param data [Hash]
  #   @key task_public_uid      [String]
  #   @key assignee_public_uid  [String]
  #   @key task_title           [String]
  #   @key jira_id              [String]
  # @return [Task]
  def create_as_consumer!(data)
    gateway.create!(
      public_uid: data[:task_public_uid],
      assig: data[:assignee_public_uid],
      title: data[:task_title],
      jira_id: data[:task_title]
    )
  end

  private

  # @return [Class<Task>]
  def gateway = Task
end
