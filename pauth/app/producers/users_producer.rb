# frozen_string_literal: true

class UsersProducer
  include Aux::Pluggable

  register initialize: true, memoize: true

  TOPIC = 'users-streaming'

  # @param event_name [String]
  # @param user       [User]
  # @raise            [Rdkafka::RdkafkaError]
  # @raise            [WaterDrop::Errors::MessageInvalidError]
  # @return           [Rdkafka::Producer::DeliveryHandle]
  def produce_async(event_name, user)
    event = build_user_event(event_name, user)
    producer.produce_async(topic: TOPIC, payload: event.to_json)
  end

  private

  # @param event_name [String]
  # @param user       [User]
  # @return           [Hash]
  def build_user_event(event_name, user)
    {
      event_name:,
      data: {
        public_uid: user.public_uid,
        email: user.email,
        admin: user.admin
      }
    }
  end

  # @return [<WaterDrop::Producer>]
  def producer
    WaterDrop::Producer.new do |config|
      config.deliver = true
      config.kafka = {
        'bootstrap.servers': Settings.kafka.host,
        'request.required.acks': 1
      }
    end
  end
end