# frozen_string_literal: true

class UsersController < ApplicationController
  include UsersHelper

  before_action :authenticate_user!, only: [:index]

  EVENT_NAME = 'user.updated'

  def current
    render status: :ok, json: current_user
  end

  def index
    @users = current_user.admin? ? users_repository.all : [current_user]
  end

  def edit; end

  def update
    if current_user&.update!(build_attributes(params))
      users_producer.produce_async(EVENT_NAME, current_user)

      redirect_to root_path
    else
      render(status: :unprocessable_entity, json: { message: 'Wrong!!!! Wrong!! Yu stupid' })
    end
  end

  # @return [User]
  def current_user
    if doorkeeper_token
      @current_user ||= users_repository.find(doorkeeper_token.resource_owner_id)
    else
      super
    end
  end
end
