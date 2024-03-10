# frozen_string_literal: true

class Task < ApplicationRecord
  # @!method assignee
  #   @return [ActiveRecord::Associations::CollectionProxy<Session>]
  has_one :assignee, class_name: "User", foreign_key: :assignee_id
end
