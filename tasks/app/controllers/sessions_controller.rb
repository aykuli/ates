# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :authenticate, only: :destroy

  def new; end

  def create
    session = create_session!(request)

    redirect_to session ? root_path : login_path
  end

  def destroy
    current_user.sessions.destroy_all

    redirect_to logout_url, allow_other_host: true
  end

  private

  # @param request [ActionDispatch::Request]
  # @return [Session, nil]
  def create_session!(request)
    auth = request.env['omniauth.auth']
    return unless auth && auth[:info]

    current_user = users_repository.find_or_create_by!(public_uid: auth[:info][:public_uid])
    return unless current_user

    manage_sessions(current_user, request, auth)
  end

  # @param current_user [User]
  # @param request      [ActionDispatch::Request]
  # @param auth         [OmniAuth::AuthHash]
  # @return             [Session, nil]
  def manage_sessions(current_user, request, auth)
    current_user.update!(email: auth[:info][:email], admin: auth[:info][:admin] || false)
    current_user.sessions.destroy_all
    sessions_repository.create!(
      id: request.session[:session_id],
      user_id: current_user.id,
      refresh_token: auth[:credentials][:refresh_token],
      expires_in: auth[:credentials][:expires_at]
    )
  end
end
