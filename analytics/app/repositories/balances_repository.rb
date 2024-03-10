# frozen_string_literal: true

class BalancesRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method find_by(attributes)
  #   @param attributes [Hash]
  #   @return [Balance]
  # delegate :find_by, to: :gateway

  # @param user [User]
  # @return [Balance]
  def last_record(user) = gateway.find_by(user_id: user.id).last

  # @return [ActiveRecord::Collection<Balance>]
  def users_in_debt = gateway.where('current < 0').distinct(:user_id)

  private

  # @return [Class<Balance>]
  def gateway = Balance
end