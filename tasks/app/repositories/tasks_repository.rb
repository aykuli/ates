# frozen_string_literal: true

class TasksRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method all
  #   @return [ActiveRecord::Relation<Task>]
  # @!method where(attributes)
  #   @param attributes [Hash]
  #   @return [ActiveRecord::Relation<Task>]
  # @!method find_by(attributes)
  #   @param attributes [Hash]
  #   @return [Task, nil]
  # @!method find(id)
  #   @param id [Integer]
  #   @raise [ActiveRecord::RecordNotFound]
  #   @return [Task]
  # @!method create!(attributes)
  #   @param attributes [Hash]
  #   @return [Task]
  delegate :all, :where, :find_by, :find, :create!, to: :gateway

  # @param criteria [Hash]
  # @return [ActiveRecord::Relation<Task>]
  def filter(criteria = {}) = query_builder.build(gateway.all, **criteria)

  private

  # @return [Class<Task>]
  def gateway = Task

  # @return [Class<TasksQueryBuilder>]
  def query_builder = TasksQueryBuilder
end
