# frozen_string_literal: true

class Event < ApplicationRecord
  # @!method task
  #   @return [Task]
  belongs_to :task

  # @!method user
  #   @return [User]
  belongs_to :user

  # @!method assignee
  #   @return [User]
  belongs_to :assignee, class_name: 'User', optional: true

  # @!method state
  #   @return [State]
  belongs_to :state
end
