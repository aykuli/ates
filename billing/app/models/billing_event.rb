# frozen_string_literal: true

class BillingEvent < ApplicationRecord
  # @!method task_cost
  #   @return [Task]
  belongs_to :task

  # @!method user
  #   @return [User]
  belongs_to :user

  # @!method state
  #   @return [AccountState]
  belongs_to :state, class_name: 'AccountState'
end
