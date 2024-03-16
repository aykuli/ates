# frozen_string_literal: true

module Recorder
  # Wrapper for adapter
  class Agent
    include Aux::Pluggable

    register initialize: true, memoize: true
    register initialize: true, memoize: true, scope: nil, as: :logger

    # @!method write(data)
    # @!method fatal(data)
    # @!method error(data)
    # @!method warn(data)
    # @!method info(data)
    # @!method debug(data)
    delegate :write, :fatal, :error, :warn, :info, :debug, to: :adapter

    # @!attribute [r] adapter
    #   @return [Recorder::ClickhouseAdapter]
    resolve :clickhouse_adapter, scope: :recorder, as: :adapter
  end
end
