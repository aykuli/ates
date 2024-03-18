# frozen_string_literal: true

FactoryBot.define do
  factory(:event, class: Event) do
    task     factory: :task
    state    factory: :state
    user     factory: :user
    assignee { nil }
  end
end
