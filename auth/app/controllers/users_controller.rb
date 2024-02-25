# frozen_string_literal: true

class UsersController
  before_filter :authenticate_user!, only: [:index]

  def index = User.all

  private

  def current_user
    if doorkeeper_token
      @current_user ||= User.find(doorkeeper_token.resource_owner_id)
    else
      super
    end
  end

  def set_user
    @current_user = User.find(params[:id])
  end
end
