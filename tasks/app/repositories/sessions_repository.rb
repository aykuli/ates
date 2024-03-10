# frozen_string_literal: true

class SessionsRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method create!(attributes)
  #   @param attributes [Hash]
  #   @return [Session]
  delegate :create!, to: :gateway

  private

  # @return [Class<Session>]
  def gateway = Session
end
