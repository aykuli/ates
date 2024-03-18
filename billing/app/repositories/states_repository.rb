# frozen_string_literal: true

class StatesRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method find_by(attributes)
  #   @param attributes [Hash]
  #   @return           [AccountState]
  delegate :find_by, to: :gateway

  private

  # @return [Class<AccountState>]
  def gateway = AccountState
end
