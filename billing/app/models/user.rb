# frozen_string_literal: true

class User < ApplicationRecord
  # @!method billing_events
  #   @return [BillingEvent]
  has_many :billing_events, dependent: :restrict_with_exception

  # @!method billing_events
  #   @return [ActiveRecord::Associations::CollectionProxy<Session>]
  has_many :sessions, dependent: :restrict_with_exception
end
