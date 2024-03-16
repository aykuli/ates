# frozen_string_literal: true

FactoryBot.define do
  factory(:state, class: State) do
    title { FFaker::Lorem.word }
    code  { FFaker::Lorem.word }
  end
end
