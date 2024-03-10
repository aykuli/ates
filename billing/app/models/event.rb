# frozen_string_literal: true

class Event < ApplicationRecord
  # @!method task_cost
  #   @return [Task]
  belongs_to :task

  # @!method user
  #   @return [User]
  belongs_to :user

  # @!method state
  #   @return [State]
  belongs_to :state
end
