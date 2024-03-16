# frozen_string_literal: true

class TasksRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method find_by!(attributes)
  #   @param attributes [Hash]
  #   @return           [Task]
  # @!method create!(attributes)
  #   @param attributes [Hash]
  #   @return           [Task]
  delegate :find_by, :create!, to: :gateway

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  #   @key state            [String]
  # @return [Task]
  def create_as_consumer!(task_data)
    gateway.create!(
      user_public_uid: task_data[:user_public_uid],
      public_uid: task_data[:public_uid],
      title: task_data[:title],
      jira_id: task_data[:jira_id],
      state: 'created'
    )
  end

  private

  # @return [Class<Task>]
  def gateway = Task
end
