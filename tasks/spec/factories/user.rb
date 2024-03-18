# frozen_string_literal: true

FactoryBot.define do
  factory(:user, class: User) do
    email       { FFaker::Internet.email }
    admin       { false }
    public_uid { SecureRandom.uuid }
  end
end
