# frozen_string_literal: true

class EventsRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method where(attributes)
  #   @param attributes [Hash]
  #   @return [ActiveRecord::Relation<BillingEvent>]
  delegate :where, to: :gateway

  # @param user [User]
  # @return [Integer, Float]
  def today_balance(user)
    today_events = gateway.where(user_id: user.id, created_at: Time.zone.now.all_day)
    today_events.inject(0) do |memo, event|
      if event.state.code == AccountStates::EARNED
        memo + event.cost
      elsif event.state.code == AccountStates::DEDUCTED
        memo - event.cost
      else
        memo
      end
    end
  end

  private

  # @return [Class<BillingEvent>]
  def gateway = BillingEvent
end
