# frozen_string_literal: true

class AnalyticsUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] balances_repository
  #   @return [BalancesRepository]
  resolve :balances_repository

  # @return [Balance]
  def management_current_balance
    top_management = users_repository.find_by(admin: true)

    balances_repository.last_record(user: top_management)
  end
end
