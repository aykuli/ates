# frozen_string_literal: true

ClickHouse.config do |config|
  config.logger = Logger.new($stdout)
  config.adapter = :net_http
  config.database = Settings.clickhouse.database
  config.scheme = Settings.clickhouse.scheme
  config.host = Settings.clickhouse.host
  config.port = Settings.clickhouse.port
  config.timeout = 60
  config.open_timeout = 3
  config.ssl_verify = false
  # set to true to symbolize keys for SELECT and INSERT statements (type casting)
  config.symbolize_keys = false
  config.headers = {}

  # if you use HTTP basic Auth
  config.username = Settings.clickhouse.user
  config.password = Settings.clickhouse.password

  # if you want to add settings to all queries
  config.global_params = {
    mutations_sync: 1,
    allow_experimental_object_type: 1,
    input_format_import_nested_json: 1
  }
end
