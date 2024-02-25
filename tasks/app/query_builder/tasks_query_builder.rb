# frozen_string_literal: true

class TasksQueryBuilder
  # @!attribute [r] query
  #   @return [ActiveRecord::Relation]
  attr_reader :query

  # @param query [ActiveRecord::Relation]
  # @param criteria [Hash]
  def initialize(query = nil, criteria = {})
    @query = query
    @criteria = criteria
  end

  # @param query [ActiveRecord::Relation]
  def reflect(query)
    self.class.new(query, criteria)
  end

  # @param query [ActiveRecord::Relation, nil]
  # @return [ActiveRecord::Relation]
  def self.build(query = nil, **criteria)
    criteria.reduce(new(query, criteria)) do |query_builder, (key, value)|
      query_builder.public_send("by_#{key}", value)
    end.query
  end

  # @param assignee_id [Integer]
  # @return [self]
  def by_assignee_id(assignee_id) = reflect(query.joins(:events).where(events: { assignee_id: }).distinct(:id))

  # @param code [String]
  # @return [self]
  def by_state(code) = reflect(with_last_event.query.where(last_event: { code: }))

  private

  # @!attribute [r] criteria
  #   @return [Hash]
  attr_reader :criteria

  def with_last_event
    reflect(query.joins(arel.sql(<<-SQL.squish)))
    INNER JOIN (
        SELECT DISTINCT ON (task_id) task_id, states.code AS code
        FROM events
        INNER JOIN states ON events.state_id = states.id
        ORDER BY task_id, events.id DESC
    ) last_event ON last_event.task_id = tasks.id
    SQL
  end

  # @return [Module<Arel>]
  def arel
    Arel
  end
end
