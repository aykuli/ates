# frozen_string_literal: true

class TasksConsumer < ApplicationConsumer
  include Aux::Pluggable

  # @!attribute [r] tasks_use_case
  #   @return [TasksUseCase]
  resolve :tasks_use_case
  # @!attribute [r] billings_use_case
  #   @return [BillingsUseCase]
  resolve :billings_use_case

  def consume
    messages.each do |message|
      task_data = take_task_from(message.payload)

      case [message.payload['event_name'], message.payload['event_version']]
      when ['task.created', 2]
        tasks_use_case.create(task_data)

      when ['task.assigned', 1]
        billings_use_case.charge_payments(task_data)

      when ['task.reassigned', 1]
        billings_use_case.recharge_payments(task_data)

      when ['task.completed', 1]
        billings_use_case.pay_for_completed_task(task_data)
      end
    end
  end

  private

  # @param payload          [Hash]
  # @key event_time         [String]
  # @key data               [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  def take_task_from(payload)
    task_data = payload['data']
    {
      public_uid: task_data.delete('task_public_uid'),
      user_public_uid: task_data.delete('user_public_uid'),
      title: task_data.delete('task_title'),
      jira_id: task_data.delete('task_jira_id'),
      updated_at: task_data.delete('task_updated_at')
    }
  end
end
