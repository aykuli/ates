# frozen_string_literal: true

class BillingsConsumer
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] balances_use_case
  #   @return [BalancesUseCase]
  resolve :balances_use_case

  def consume
    messages.each do |message|
      billing_data = take_billing(message.payload['data'])

      case [message.payload['event_name'], message.payload['event_version']]
      when ['billing.deposited', 1]
        balances_use_case.deposited(billing_data)

      when ['billing.withdrawn', 1]
        balances_use_case.withdrawn(billing_data)

      when ['billing.task_costs_counted', 1]
        balances_use_case.save_task_costs(take_task_costs(message.payload['data']))
      end
    end
  end

  private

  # @param data            [Hash]
  #   @key cost            [Float]
  #   @key user_public_uid [String]
  #   @key task_public_uid [String]
  #   @key created_at      [String]
  # @return                [Hash]
  def take_billing(data)
    {
      cost: data.delete('cost'),
      user_public_uid: data.delete('user_public_uid'),
      task_public_uid: data.delete('task_public_uid'),
      created_at: data.delete('created_at')
    }
  end

  # @param data               [Hash]
  #   @key task_public_uid   [String]
  #   @key task_assign_cost  [Float]
  #   @key task_solving_cost [Float]
  # @return                  [Hash]
  def take_task_costs(data)
    {
      task_public_uid: data.delete('task_public_uid'),
      task_assign_cost: data.delete('task_assign_cost'),
      task_solving_cost: data.delete('task_solving_cost')
    }
  end
end
