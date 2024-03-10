# frozen_string_literal: true

class TasksConsumer < ApplicationConsumer
  include Aux::Pluggable

  # @!attribute [r] task_costs_use_case
  #   @return [TaskCostsUseCase]
  resolve :task_costs_use_case
  # @!attribute [r] tasks_use_case
  #   @return [TasksUseCase]
  resolve :tasks_use_case

  # rubocop:disable
  def consume
    messages.each do |message|
      task_data = take_task_data_from(message.payload['data'])

      case [message.payload['event_name'], message.payload['event_version']]
      when ['task.assigned', 2]
        task = tasks_use_case.create!(task_data)
        task_costs_use_case.count_payments!(task)
      when ['task.reassigned', 1]
        task_costs_use_case.reassign_payments!(task_data)
      when ['task.done', 1]
        task_costs_use_case.done_payments!(task_data)
      end
    end
  end

  private

  # @param data                 [Hash]
  #   @key task_public_uid      [String]
  #   @key assignee_public_uid  [String]
  #   @key task_title           [String]
  #   @key jira_id              [String]
  def take_task_data_from(data)
    {
      public_uid: data.delete('task_public_uid'),
      assignee_public_uid: data.delete('assignee_public_uid'),
      title: data.delete('task_title'),
      jira_id: data.delete('jira_id')
    }
  end
end
