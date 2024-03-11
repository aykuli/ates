# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': 'localhost:9092' }
    config.client_id = 'tasks_service'
    config.consumer_persistence = !Rails.env.development?
  end

  routes.draw do
    topic 'users-streaming' do
      consumer UsersConsumer
    end
    topic 'tasks-streaming' do
      consumer TasksConsumer

      dead_letter_queue(
        topic: 'tasks-streaming-dead-messages',
        max_retries: 2,
        independent: false
      )
    end
  end
end
