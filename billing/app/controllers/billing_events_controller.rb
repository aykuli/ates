# frozen_string_literal: true

class BillingEventsController < ApplicationController
  before_action :authenticate

  def index
    @billing_events = billing_events_repository.where(user_id: current_user.id)
    @current_balance = billing_events_repository.today_balance(current_user)
  end

  private

  def summarizer = Rails.configuration.ioc.resolve('summarize_users_balance_worker')
end
