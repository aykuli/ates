class CreateClickhouseTables < ActiveRecord::Migration[7.1]
  ClickHouse.connection.create_table(:logs,
                                     if_not_exists: true,
                                     ttl: 'created_at + INTERVAL 2 MONTH',
                                     engine: 'MergeTree',
                                     order: 'created_at') do |t|
    t.DateTime :created_at, "UTC", nullable: false, default: "now()"
    t.String   :message
    t.String   :producer, default: nil
    t.String   :level
    t.JSON     :payload
  end
end
