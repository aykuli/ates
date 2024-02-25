# frozen_string_literal: true

class Task < ApplicationRecord
  # @!method events
  #   @return [ActiveRecord::Associations::CollectionProxy<Event>]
  has_many :events, dependent: :destroy

  # @!method last_event
  #   @return [Event]
  has_one :last_event, -> { order(id: :desc) }, class_name: 'Event', inverse_of: :task, dependent: :destroy

  # @!method status
  #   @return [State]
  has_one :state, class_name: 'State', through: :last_event, source: :state

  # @!method assignee
  #   @return [User]
  def assignee = fetch_last_event_by_code(code: [States::ASSIGNED, States::REASSIGNED])&.last&.assignee

  private

  # @param code [String, Symbol, Array<String>, Array<Symbol>]
  # @return     [Event, nil]
  def fetch_last_event_by_code(code:) = events.joins(:state).where(state: { code: })
end
