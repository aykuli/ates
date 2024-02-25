# frozen_string_literal: true

class Session < ApplicationRecord
  # @!attribute [rw] user
  #   @return [User]
  belongs_to :user, class_name: 'User'

  # @!method [r] token
  #   @return [String]
  alias_attribute :token, :id
end
