class BillingsProducer
  include Aux::Pluggable

  register initialize: true, memoize: true

  TOPIC = 'billing-streaming'
  PRODUCER = 'billing-service'
  SCHEMA_NAME = 'billing'

  # @param billing_events  [Array<Event>]
  # @param version        [Integer]
  # @raise                [Rdkafka::RdkafkaError]
  # @raise                [WaterDrop::Errors::MessageInvalidError]
  # @return               [Array<Rdkafka::Producer::DeliveryHandle>]
  def produce_many_async(billing_events, version: 1)
    state_code = billing_events.first&.state&.code
    logger.error(message: "Wrong state of billing event: #{billing_events.to_s}", producer: PRODUCER) unless state_code

    events = billing_events.map { build_event(_1.state.code, prepare(_1)).merge(event_version: version) }
    result = SchemaRegistry.validate_event(events, "#{SCHEMA_NAME}.#{state_code}", version:)

    if result.success?
      produce_many(events)
    else
      result.result.each { logger.error(message: "validator_message: #{_1}, event: #{::JSON.serialize(_1)}" , producer: PRODUCER) }
    end
  end

  private

  # @param events [Array<Hash>]
  # @raise        [Rdkafka::RdkafkaError]
  # @raise        [WaterDrop::Errors::MessageInvalidError]
  # @return       [Array<Rdkafka::Producer::DeliveryHandle>]
  def produce_many(events)
    Karafka.producer.produce_many_async(events.map { { topic: TOPIC, payload: _1.to_json } })
  end

  # @param state_code [String]
  # @param data       [Hash]
  # @return           [Hash]
  def build_event(state_code, data)
    {
      event_name: "task.#{state_code}",
      event_uid: SecureRandom.uuid,
      event_time: Time.zone.now.to_s,
      producer: PRODUCER,
      data:
    }
  end

  # @param event [Event]
  # @return     [Hash]
  def prepare(event)
    {
      event_public_uid: event.public_uid,
      event_state: event.state.slice(:code, :title),
      user_public_uid: event.user.public_uid,
      cost: event.cost
    }
  end

end