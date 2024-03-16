# frozen_string_literal: true

class Balance < ApplicationRecord
  has_one :user
end
