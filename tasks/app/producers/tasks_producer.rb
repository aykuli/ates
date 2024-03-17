# frozen_string_literal: true

class TasksProducer
  include Aux::Pluggable

  register initialize: true, memoize: true

  TOPIC = 'tasks-streaming'

  # @param task       [Task]
  # @raise            [Rdkafka::RdkafkaError]
  # @raise            [WaterDrop::Errors::MessageInvalidError]
  # @return           [Rdkafka::Producer::DeliveryHandle]
  def produce_async(task)
    event = build_event(task)

    produce(event)
  end

  # @param tasks      [Array<Task>]
  # @return           [Array<Rdkafka::Producer::DeliveryHandle>]
  def produce_many_async(tasks)
    events = tasks.map { build_event(_1) }

    produce_many(events)
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

  # @param task [Task]
  # @return     [Hash]
  def build_event(task)
    {
      event_name: "task.#{task.state.code}",
      data: {
        task_public_uid: task.public_uid,
        task_title: task.title,
        assignee_public_uid: task.assignee.public_uid
      }
    }
  end
end
