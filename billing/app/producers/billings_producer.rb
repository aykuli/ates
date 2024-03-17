# frozen_string_literal: true

class BillingsProducer
  include Aux::Pluggable

  register initialize: true, memoize: true

  TOPIC = 'billings-streaming'
  PRODUCER = 'billing-service'
  SCHEMA_NAME = 'billing'

  # @!method validator
  #   @return [BillingsValidator]
  resolve :billings_validator, as: :validator
  # @!method logger
  #   @return [Recorder::Agent]
  resolve :logger

  # @param task [Task]
  def produce_async(event_name, task, version: 1)
    data = {
      task_public_uid: task.public_uid,
      task_assign_cost: task.assign_cost,
      task_solving_cost: task.solving_cost
    }

    event = build_event(event_name, data).merge(event_version: version)
    valid = validator.valid?(event, "#{SCHEMA_NAME}.#{event_name}", version:)

    produce(event) if valid
  end

  # @param billing_events [Array<BillingEvent>]
  def produce_many_async(billing_events, version: 1)
    valid = false
    events = []
    billing_events.each do |be|
      event = build_event(be.state.code, prepare(be)).merge(event_version: version)
      valid = validator.valid?(event, "#{SCHEMA_NAME}.#{be.state.code}", version:)

      events << event if valid
    end

    produce_many(events) if valid
  end

  private

  # @param event  [Hash]
  # @raise        [Rdkafka::RdkafkaError]
  # @raise        [WaterDrop::Errors::MessageInvalidError]
  # @return       [Rdkafka::Producer::DeliveryHandle]
  def produce(event)
    Karafka.producer.produce_async(topic: TOPIC, payload: event.to_json)
  rescue e
    logger.error(message: e.message, producer: PRODUCER, payload: events.to_s)
  end

  # @param events [Array<Hash>]
  # @raise        [Rdkafka::RdkafkaError]
  # @raise        [WaterDrop::Errors::MessageInvalidError]
  # @return       [Array<Rdkafka::Producer::DeliveryHandle>]
  def produce_many(events)
    events_with_topic = events.map { { topic: TOPIC, payload: _1.to_json } }
    Karafka.producer.produce_many_async(events_with_topic)
  rescue e
    logger.error(message: e.message, producer: PRODUCER, payload: events.to_s)
  end

  # @param event_name [String]
  # @param data       [Hash]
  # @return           [Hash]
  def build_event(event_name, data)
    {
      event_name: "#{SCHEMA_NAME}.#{event_name}",
      event_uid: SecureRandom.uuid,
      event_time: Time.zone.now.to_s,
      producer: PRODUCER,
      data:
    }
  end

  # @param billing_event [BillingEvent]
  # @return              [Hash]
  def prepare(billing_event)
    {
      cost: billing_event.cost,
      user_public_uid: billing_event.user.public_uid,
      task_public_uid: billing_event.task.public_uid,
      billing_updated_at: billing_event.created_at.to_s
    }
  end
end
