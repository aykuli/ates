# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': Settings.kafka.host }
    config.client_id = 'analytics_service'
    config.consumer_persistence = !Rails.env.development?
  end

  routes.draw do
  end
end
