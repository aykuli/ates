# frozen_string_literal: true

class EventsRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method where(attributes)
  #   @param attributes [Hash]
  #   @return [ActiveRecord::Relation<Event>]
  delegate :where, to: :gateway

  # @param user [User]
  # @return [Integer, Float]
  def today_balance(user)
    today_events = gateway.where(user_id: user.id, created_at: Time.zone.now.all_day)
    today_events.inject(0) do |memo, event|
      if event.state.code == States::EARNED
        memo + event.cost
      elsif event.state.code == States::DEDUCTED
        memo - event.cost
      else
        memo
      end
    end
  end

  private

  # @return [Class<Event>]
  def gateway = Event
end
