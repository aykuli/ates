# frozen_string_literal: true

class TaskCostsRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method find_by!(attributes)
  #   @param attributes [Hash]
  #   @return           [Task]
  delegate :find_by, to: :gateway

  # @!method create_activity_costs!!(task)
  #   @param task [Task]
  #   @return     [TaskCost]
  def create_activity_costs!(task) = gateway.create!(task_id: task.id, assign_cost: rand(10..20), solving_cost: rand(20..40))

  private

  # @return [Class<Task>]
  def gateway = Task
end
