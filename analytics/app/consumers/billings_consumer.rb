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
      when ["billing.deposited", 1]
        balances_use_case.deposited(billing_data)

      when ["billing.withdrawn", 1]
        balances_use_case.withdrawn(billing_data)
      end
    end
  end

  private

  # @param data    [Hash]
  #   @key cost            [Hash]
  #   @key user_public_uid [String]
  #   @key task_public_uid [String]
  #   @key created_at      [String]
  def take_billing(data)
    {
      cost: data.delete('cost'),
      user_public_uid: data.delete('user_public_uid'),
      task_public_uid: data.delete('task_public_uid'),
      created_at: data.delete('created_at')
    }
  end
end
