# frozen_string_literal: true

class SessionsRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method create!(attributes)
  #   @param attributes [Hash]
  #   @return [Session]
  delegate :create!, to: :gateway

  # @param token [String]
  # @return [User, nil]
  def find_by_session(token)
    result = gateway.joins(:sessions).where(sessions: { id: token }).limit(1)
    return result.first if result.any?

    nil
  end

  private

  # @return [Class<Session>]
  def gateway = Session
end
