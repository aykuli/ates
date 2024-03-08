# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  # @!attribute [r] current_user
  #   @return [APM::Base::User]
  attr_reader :current_user

  def authenticate
    @current_user = users_repository.find_by_session(request.session[:session_id])

    redirect_to login_path unless @current_user
  end

  def permitted_params(command) = params.permit(command.schema.keys.map(&:name))

  def users_repository = Rails.configuration.ioc.resolve('users_repository')
  def sessions_repository = Rails.configuration.ioc.resolve('sessions_repository')
end
