# frozen_string_literal: true

require 'karafka/web'

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': Settings.kafka.host }
    config.client_id = 'tasks_service'
    config.consumer_persistence = !Rails.env.development?
  end

  routes.draw do
    topic 'users-streaming' do
      consumer UsersConsumer
    end
  end
end
