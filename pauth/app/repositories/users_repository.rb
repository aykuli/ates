# frozen_string_literal: true

class UsersRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method all!(attributes)
  #   @param attributes [Hash]
  #   @return [ActiveRecord::Associations::CollectionProxy<User>]
  # @!method create!(attributes)
  #   @param attributes [Hash]
  #   @return [User]
  # @!method find(attributes)
  #   @param attributes [Hash]
  #   @return [User, nil]
  delegate :all, :create!, :find, to: :gateway

  private

  # @return [Class<User>]
  def gateway = User
end
