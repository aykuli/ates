# frozen_string_literal: true

class BillingsConsumer
  include Aux::Pluggable

  register initialize: true, memoize: true

  EARNED_EVENT_NAME   = 'earned'
  DEDUCTED_EVENT_NAME = 'deducted'

  # @!attribute [r] balances_use_case
  #   @return [BalancesUseCase]
  resolve :balances_use_case

  def consume
    messages.each do |message|
      billing_data = take_billing(message.payload)

      case [message.payload['event_name'], message.payload['event_version']]
      when ["billing.#{EARNED_EVENT_NAME}", 1]
        balances_use_case.write(EARNED_EVENT_NAME, billing_data)

      when ["billing.#{DEDUCTED_EVENT_NAME}", 1]
        balances_use_case.write(DEDUCTED_EVENT_NAME, billing_data)
      end
    end
  end

  private

  # @param payload    [Hash]
  #   @key data       [Hash]
  #   @key event_time [String]
  def take_billing(payload)
    data = payload['data']
    event_time = payload['event_time']

    {
      cost: data.delete('cost'),
      task_public_uid: data.delete('task_public_uid'),
      assignee_public_uid: data.delete('assignee_public_uid'),
      event_time:
    }
  end
end
