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
  # @!method find_or_create_by!(attributes)
  #   @param attributes [Hash]
  #   @return [User]
  delegate :find_by, :create!, :find_or_create_by!, to: :gateway

  # @param token [String]
  # @return [User, nil]
  def find_by_session(token)
    result = gateway.joins(:sessions).where(sessions: { id: token }).limit(1)
    return result.first if result.any?

    nil
  end

  # @return [Integer]
  def popugs_quantity_in_debt
    quantity = 0
    gateway.where(admin: false).find_each do
      quantity += 1 if _1.current_balance.negative?
    end

    quantity
  end

  private

  # @return [Class<User>]
  def gateway = User
end
