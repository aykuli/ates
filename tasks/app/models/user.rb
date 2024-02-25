# frozen_string_literal: true

class User < ApplicationRecord
  # @!method tasks
  #   @return [ActiveRecord::Associations::CollectionProxy<Task>]
  has_many :tasks, dependent: :restrict_with_exception

  # @!method sessions
  #   @return [ActiveRecord::Associations::CollectionProxy<Session>]
  has_many :sessions, dependent: :restrict_with_exception
end
