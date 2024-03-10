# frozen_string_literal: true

class User < ApplicationRecord
  # @!method events
  #   @return [Event]
  has_many :events, dependent: :restrict_with_exception

  # @!method events
  #   @return [ActiveRecord::Associations::CollectionProxy<Session>]
  has_many :sessions, dependent: :restrict_with_exception

  # @param token [String]
  # @return [User, nil]
  def find_by_session(token)
    result = User.joins(:sessions).where(sessions: { id: token }).limit(1)
    return result.first if result.any?

    nil
  end
end
