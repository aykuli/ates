# frozen_string_literal: true

class StatesRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method find_by(attributes)
  #   @param attributes [Hash]
  #   @return [State, nil]
  delegate :find_by, to: :gateway

  private

  # @return [Class<State>]
  def gateway = State
end
