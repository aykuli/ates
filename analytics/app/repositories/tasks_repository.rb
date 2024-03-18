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
  #   @return [Array<Hash>]
  # TODO make separate table for costs by day writes summary row everyday by schedule
  def costly_solved_tasks_by_day
    tasks_all = gateway.where(state: 'completed').order(updated_at: :desc)
    tasks_result = []
    task_day = nil
    max_solving_cost = 0
    task_with_max_cost = nil

    tasks_all.each_with_index do |task, index|
      # if the new day loop
      if task_day == task.updated_at.strftime('%Y-%m-%d')
        if task.solving_cost > max_solving_cost
          max_solving_cost = task.solving_cost
          task_with_max_cost = task
        end
      else
        # save yesterday max_cost task
        unless task_with_max_cost.nil?
          tasks_result << { cost: task_with_max_cost.solving_cost,
                            date: task_with_max_cost.updated_at.strftime('%Y-%m-%d') }
        end

        # reset markers
        task_day = task.updated_at.strftime('%Y-%m-%d')
        max_solving_cost = task.solving_cost
        task_with_max_cost = task
      end

      if index == tasks_all.size - 1
        tasks_result << { cost: task_with_max_cost.solving_cost,
                          date: task_with_max_cost.updated_at.strftime('%Y-%m-%d') }
      end
    end

    tasks_result
  end

  private

  # @return [Class<Task>]
  def gateway = Task
end
