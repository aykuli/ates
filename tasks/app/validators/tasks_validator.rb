# frozen_string_literal: true

class TasksValidator
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method logger
  #   @return [Recorder::Agent]
  resolve :logger

  # @param event   [Hash]
  # @param type    [String]
  # @param version [Integer]
  # @return        [Boolean]
  def valid?(event, type, version: 1)
    validation = schema_registry.validate_event(event, type, version:)
    return true if validation.success?

    logger.error(message: validation.result.join(':'), producer: 'TasksValidator.valid?', payload: event.to_s)

    false
  end

  private

  # @return [Module<SchemaRegistry>]
  def schema_registry = SchemaRegistry
end
