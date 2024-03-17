# frozen_string_literal: true

class User < ApplicationRecord
  # @!method  sessions
  #   @return [ActiveRecord::Associations::CollectionProxy<Session>]
  has_many :sessions, dependent: :restrict_with_exception

  # @!method  balance_flow
  #   @return [ActiveRecord::Associations::CollectionProxy<Balance>]
  has_many :balance_flow, class_name: 'Balance'

  # @return [Float]
  def current_balance = balance_flow.empty? ? 0 : balance_flow.last.current
end
