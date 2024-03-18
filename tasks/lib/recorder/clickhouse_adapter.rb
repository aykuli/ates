# frozen_string_literal: true

require 'click_house'

module Recorder
  class ClickhouseAdapter
    include Recorder::AdapterInterface
    include Aux::Pluggable

    register initialize: true, memoize: true

    private

    # @param data [Hash]
    # @return [ClickHouse::Response::Execution]
    def write(data)
      agent.insert("#{Settings.clickhouse.database}.logs", data)
    end

    # @return [ClickHouse::Connection]
    def agent = @agent ||= ClickHouse::Connection.new(ClickHouse.config)

    # @return [String]
    def environment = Rails.env.to_s
  end
end
