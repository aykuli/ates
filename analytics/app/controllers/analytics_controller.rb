# frozen_string_literal: true

class AnalyticsController < ApplicationController
  before_action :authenticate

  def index
    top_management = users_repository.find_by(admin: true)
    @management_balance = top_management.current_balance

    @popugs_quantity_in_debt = users_repository.popugs_quantity_in_debt

    @tasks = tasks_repository.costly_solved_tasks_by_day # TODO: pagination
  end
end
