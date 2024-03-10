class BillingsProducer
  include Aux::Pluggable

  register initialize: true, memoize: true

  TOPIC = 'billings-streaming'
  PRODUCER = 'billing-service'
  SCHEMA_NAME = 'billing'

  MANAGEMENT_EARN_EVENT     = 'earned'
  MANAGEMENT_DEDUCTED_EVENT = 'deducted'

  # @param event_name [String]
  # @param task       [Task]
  # @param version    [Integer]
  # @raise            [Rdkafka::RdkafkaError]
  # @raise            [WaterDrop::Errors::MessageInvalidError]
  # @return           [Rdkafka::Producer::DeliveryHandle]
  def produce_async(event_name, task, version: 1)
    event = build_event(event_name, task)

    result = SchemaRegistry.validate_event(event, "#{SCHEMA_NAME}.#{event_name}", version:)

    if result.success?
      produce(event)
    else
      result.result.each { logger.error(message: _1, producer: PRODUCER) }
    end
  end

  private

  # @param events [Hash]
  # @raise        [Rdkafka::RdkafkaError]
  # @raise        [WaterDrop::Errors::MessageInvalidError]
  # @return       [Rdkafka::Producer::DeliveryHandle]
  def produce(events)
    Karafka.producer.produce_many_async(events.map { { topic: TOPIC, payload: _1.to_json } })
  end

  # @param event_name [String]
  # @param task       [Task]
  # @return           [Hash]
  def build_event(event_name, task)
    {
      event_name: "#{SCHEMA_NAME}.#{event_name}",
      event_uid: SecureRandom.uuid,
      event_time: Time.zone.now.to_s,
      producer: PRODUCER,
      data: {
        cost:                task.assign_cost,
        assignee_public_uid: task.task.assignee.public_uid,
        task_public_uid:     task.task.public_uid
      }
    }
  end
end