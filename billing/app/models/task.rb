# frozen_string_literal: true

class Task < ApplicationRecord
  # @!method user
  #   @return [ActiveRecord::Associations::CollectionProxy<Session>]
  has_one :user, class_name: 'User', foreign_key: :user_public_uuid, inverse_of: :public_uuid
end
