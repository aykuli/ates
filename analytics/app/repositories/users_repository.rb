# frozen_string_literal: true

class UsersRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method find_by(attributes)
  #   @param attributes [Hash]
  #   @return [User]
  # @!method create!(attributes)
  #   @param attributes [Hash]
  #   @return [User]
  delegate :find_by, :create!, to: :gateway

  private

  # @return [Class<User>]
  def gateway = User
end
