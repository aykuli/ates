# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  # @return [UsersRepository]
  def users_repository = Rails.configuration.ioc.resolve('users_repository')

  # @return [UsersProducer]
  def users_producer = Rails.configuration.ioc.resolve('users_producer')
end
