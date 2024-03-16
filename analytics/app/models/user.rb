# frozen_string_literal: true

class User < ApplicationRecord
  # @!method billing_events
  #   @return [ActiveRecord::Associations::CollectionProxy<Session>]
  has_many :sessions, dependent: :restrict_with_exception

  # @!method balance
  #   @return [Balance]
  has_one :balance, -> { order(id: :desc) }, class_name: 'Balance', inverse_of: :user, dependent: :destroy
end
