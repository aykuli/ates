# frozen_string_literal: true

class TasksRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method find_by!(attributes)
  #   @param attributes [Hash]
  #   @return           [Task]
  # @!method create!(attributes)
  #   @param attributes [Hash]
  #   @return           [Task]
  delegate :find_by, :create!, to: :gateway

  # @!method costly_tasks_by_day
  #   @return [ActiveRecord::Collection<Task>]
  def costly_tasks_by_day = gateway.where('todo write sql ??? logic here')

  private

  # @return [Class<Task>]
  def gateway = Task
end
