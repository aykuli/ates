# frozen_string_literal: true

class BillingsConsumer < ApplicationConsumer
  include Aux::Pluggable

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
        billing_data = take_task_costs(message)
        balances_use_case.save_task_costs(billing_data)
      end
    end
  end

  private

  # @param data              [Hash]
  #   @key cost               [Float]
  #   @key user_public_uid    [String]
  #   @key task_public_uid    [String]
  #   @key billing_updated_at [String]
  # @return                   [Hash]
  def take_billing(data)
    {
      cost: data.delete('cost'),
      user_public_uid: data.delete('user_public_uid'),
      task_public_uid: data.delete('task_public_uid'),
      updated_at: data.delete('billing_updated_at')
    }.compact
  end

  # @param message               [Hash]
  # @key payload               [Hash]
  #   @key task_public_uid   [String]
  #   @key task_assign_cost  [Float]
  #   @key task_solving_cost [Float]
  # @return                  [Hash]
  def take_task_costs(message)
    data = message.payload['data']
    if data['task_public_uid'].nil?
      raw_payload = message.raw_payload
      payload = JSON.parse(raw_payload)
      data = payload['data']
    end

    {
      task_public_uid: data.delete('task_public_uid'),
      task_assign_cost: data.delete('task_assign_cost'),
      task_solving_cost: data.delete('task_solving_cost')
    }.compact
  end
end
