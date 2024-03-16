# frozen_string_literal: true

FactoryBot.define do
  factory(:task, class: Task) do
    title   { FFaker::Lorem.word }
    jira_id { FFaker::Lorem.word }
    public_uuid { SecureRandom.uuid }
  end

  after(:create) do |task, _options|
    create(:event, task:, state: States::CREATED)
  end
end
