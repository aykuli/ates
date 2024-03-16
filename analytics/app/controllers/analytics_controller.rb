# frozen_string_literal: true

class AnalyticsController < ApplicationController
  before_action :authenticate

  def index
    @management_balance = 0
    @popugs_in_debt = 0
    @costly_tasks = 0
    @task_costs = []
    #
    # @management_balance = use_case.management_current_balance
    # @popugs_in_debt = use_case.users_in_debt.size
    # @costly_tasks = use_case.costly_tasks_by_day # TODO: pagination
  end

  private

  # @return [AnalyticsUseCase]
  def use_case = Rails.configuration.ioc.resolve('analytics_use_case')
end
