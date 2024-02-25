# frozen_string_literal: true

class UsersRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method create!(attributes)
  #   @param attributes [Hash]
  #   @return [User]
  # @!method find_by(attributes)
  #   @param attributes [Hash]
  #   @return [User, nil]
  # @!method find(attributes)
  #   @param attributes [Hash]
  #   @return [User, nil]
  # @!method find_or_create_by!(attributes)
  #   @param attributes [Hash]
  #   @return [User, nil]
  delegate :create!, :find_by, :find, :find_or_create_by!, to: :gateway

  # @return [ActiveRecord::Relation<User>]
  def take_random = gateway.where(admin: false).sample

  # @param token [String]
  # @return [User, nil]
  def find_by_session(token)
    result = gateway.joins(:sessions).where(sessions: { id: token }).limit(1)
    return result.first if result.any?

    nil
  end

  private

  # @return [Class<User>]
  def gateway = User
end
