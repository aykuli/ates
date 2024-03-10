# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate

  def index
    @events = events_repository.where(user_id: current_user.id)
    @current_balance = events_repository.today_balance(current_user)
  end

  def summarize_users_balance
    summarizer.perform_async
    redirect_to root_path
  end

  private

  def summarizer = Rails.configuration.ioc.resolve('summarize_users_balance_worker')
end
