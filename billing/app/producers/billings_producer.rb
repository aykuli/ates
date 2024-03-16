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
  # resolve :logger


  # @param billing_events [Array<BillingEvent>]
  def produce_many_async(billing_events, version: 1)
    byebug

    valid = false
    events = billing_events.map do |be|
      event = build_event(be).merge(event_version: version)
      valid = validator.valid?(event, "#{SCHEMA_NAME}.#{be.state.code}", version:)

      return event if valid

      break
    end
    byebug
    produce_many(events) if valid


  end


  private

  # @param events [Array<Hash>]
  # @raise        [Rdkafka::RdkafkaError]
  # @raise        [WaterDrop::Errors::MessageInvalidError]
  # @return       [Rdkafka::Producer::DeliveryHandle]
  def produce_many(events)
    Karafka.producer.produce_many_async(events.map { { topic: TOPIC, payload: _1.to_json } })
  rescue e
    # logger.error(message: e.message, producer: PRODUCER, payload: events.to_s)
  end

  # @param billing_event [BillingEvent]
  # @return              [Hash]
  def build_event(billing_event)
    event_name = billing_event.state.code
    byebug
    {
      event_name: "#{SCHEMA_NAME}.#{event_name}",
      event_uid: SecureRandom.uuid,
      event_time: Time.zone.now.to_s,
      producer: PRODUCER,
      data: prepare(billing_event)
    }
  end

  # @param billing_event [BillingEvent]
  # @return              [Hash]
  def prepare(billing_event)
    {
      cost: billing_event.cost,
      user_public_uid: billing_event.user.public_uid,
      task_public_uid: billing_event.task.public_uid,
      created_at: billing_event.created_at
    }
  end
end
