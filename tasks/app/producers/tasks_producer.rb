# frozen_string_literal: true

class TasksProducer
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method logger
  #   @return [TasksValidator]
  resolve :tasks_validator, as: :validator
  # @!method logger
  #   @return [Recorder::Agent]
  resolve :logger

  TOPIC = 'tasks-streaming'
  PRODUCER = 'tasks-service'
  SCHEMA_NAME = 'task'

  # @param task       [Task]
  # @param task_event [String]
  # @param version    [Integer]
  # @raise            [Rdkafka::RdkafkaError]
  # @raise            [WaterDrop::Errors::MessageInvalidError]
  # @return           [Rdkafka::Producer::DeliveryHandle]
  def produce_async(task, task_event, version: 1)
    event = build_event(task.state.code, prepare(task)).merge(event_version: version)
    valid = validator.valid?(event, "#{SCHEMA_NAME}.#{task_event}", version:)

    produce(event) if valid
  end

  # @param tasks      [Array<Task>]
  # @param version    [Integer]
  # @raise            [Rdkafka::RdkafkaError]
  # @raise            [WaterDrop::Errors::MessageInvalidError]
  # @return           [Rdkafka::Producer::DeliveryHandle]
  def produce_many_async(tasks, task_event, version: 1)
    events = tasks.map { build_event(_1.state.code, prepare(_1)).merge(event_version: version) }
    valid = validator.valid?(events, "#{SCHEMA_NAME}.#{task_event}", version:)

    produce_many(events) if valid
  end

  private

  # @param payload [Hash]
  # @raise         [Rdkafka::RdkafkaError]
  # @raise         [WaterDrop::Errors::MessageInvalidError]
  # @return        [Rdkafka::Producer::DeliveryHandle]
  def produce(payload)
    Karafka.producer.produce_async(topic: TOPIC, payload: payload.to_json)
  rescue StandardError => e
    logger.error(message: e.message, producer: PRODUCER, payload: events.to_json)
  end

  # @param events [Array<Hash>]
  # @raise        [Rdkafka::RdkafkaError]
  # @raise        [WaterDrop::Errors::MessageInvalidError]
  # @return       [Array<Rdkafka::Producer::DeliveryHandle>]
  def produce_many(events)
    Karafka.producer.produce_many_async(events.map { { topic: TOPIC, payload: _1.to_json } })
  rescue StandardError => e
    logger.error(message: e.message, producer: PRODUCER, payload: events.to_json)
  end

  # @param task_event [String]
  # @param data       [Hash]
  # @return           [Hash]
  def build_event(task_event, data)
    {
      event_name: "task.#{task_event}",
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
      user_public_uid: task.assignee.public_uid,
      task_title: task.title,
      jira_id: task.jira_id
    }
  end
end
