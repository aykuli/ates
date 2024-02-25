# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  # @!attribute [r] current_user
  #   @return [User]
  attr_reader :current_user

  def authenticate
    @current_user = users_repository.find_by_session(request.session[:session_id])

    redirect_to login_path unless @current_user
  end

  # @return [UsersRepository]
  def users_repository = Rails.configuration.ioc.resolve('users_repository')

  # @return [SessionsRepository]
  def sessions_repository = Rails.configuration.ioc.resolve('sessions_repository')

  # @return [TasksUseCase]
  def tasks_use_case = Rails.configuration.ioc.resolve('tasks_use_case')

  # @return [TasksProducer]
  def tasks_producer = Rails.configuration.ioc.resolve('tasks_producer')
end
