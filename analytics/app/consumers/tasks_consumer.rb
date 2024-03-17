# frozen_string_literal: true

class TasksConsumer < ApplicationConsumer
  include Aux::Pluggable

  # @!attribute [r] tasks_use_case
  #   @return [TasksUseCase]
  resolve :tasks_use_case

  def consume
    messages.each do |message|
      task_data = take_task_from(message)

      case [message.payload['event_name'], message.payload['event_version']]
      when ['task.created', 2]
        tasks_use_case.create(task_data.merge(state: 'created'))

      when ['task.assigned', 1]
        tasks_use_case.update(task_data.merge(state: 'assigned'))

      when ['task.reassigned', 1]
        tasks_use_case.update(task_data.merge(state: 'reassigned'))

      when ['task.completed', 1]
        tasks_use_case.update(task_data.merge(state: 'completed'))
      end
    end
  end

  private

  # @param message          [Hash]
  # @key event_name         [String]
  # @key payload            [Hash]
  def take_task_from(message)
    task_data = message.payload['data']
    {
      public_uid: task_data.delete('task_public_uid'),
      user_public_uid: task_data.delete('user_public_uid'),
      title: task_data.delete('task_title'),
      jira_id: task_data.delete('task_jira_id'),
      solving_cost: task_data.delete('task_solving_cost'),
      assign_cost: task_data.delete('task_assign_cost'),
      updated_at: task_data.delete('task_updated_at')
    }.compact
  end
end
