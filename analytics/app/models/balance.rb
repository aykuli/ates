# frozen_string_literal: true

class Balance < ApplicationRecord
  # @!method  user
  #   @return [User]
  belongs_to :user
end
