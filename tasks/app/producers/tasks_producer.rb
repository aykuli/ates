# frozen_string_literal: true

class TasksProducer
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method logger
  #   @return [Recorder::Agent]
  resolve :logger

  TOPIC = 'tasks-streaming'
  PRODUCER = 'tasks-service'
  SCHEMA_NAME = 'task'

  # @param task       [Task]
  # @param version    [Integer]
  # @raise            [Rdkafka::RdkafkaError]
  # @raise            [WaterDrop::Errors::MessageInvalidError]
  # @return           [Rdkafka::Producer::DeliveryHandle]
  def produce_async(task, version: 1)
    event = build_event(task.state.code, prepare(task)).merge(event_version: version)
    result = SchemaRegistry.validate_event(event, "#{SCHEMA_NAME}.#{task.state.code}", version:)

    if result.success?
      produce(event)
    else
      result.result.each { logger.error(message: _1, producer: PRODUCER) }
    end
  end

  # @param tasks      [Array<Task>]
  # @param version    [Integer]
  # @raise            [Rdkafka::RdkafkaError]
  # @raise            [WaterDrop::Errors::MessageInvalidError]
  # @return           [Rdkafka::Producer::DeliveryHandle]
  def produce_many_async(tasks, version: 1)
    state_code = tasks[0].state.code
    events = tasks.map { build_event(_1.state.code, prepare(_1)).merge(event_version: version) }
    result = SchemaRegistry.validate_event(events, "#{SCHEMA_NAME}.#{state_code}", version:)

    if result.success?
      produce_many(events)
    else
      result.result.each { logger.error(message: _1, producer: PRODUCER) }
    end
  end

  private

  # @param payload [Hash]
  # @raise         [Rdkafka::RdkafkaError]
  # @raise         [WaterDrop::Errors::MessageInvalidError]
  # @return        [Rdkafka::Producer::DeliveryHandle]
  def produce(payload)
    Karafka.producer.produce_async(topic: TOPIC, payload: payload.to_json)
  end

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

  # @param task [Task]
  # @return     [Hash]
  def prepare(task)
    {
      task_public_uid: task.public_uid,
      assignee_public_uid: task.assignee.public_uid,
      task_title: task.title,
      jira_id: task.jira_id
    }
  end
end
