# frozen_string_literal: true

class DoneTasksRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!method costly_tasks_by_day
  #   @return [ActiveRecord::Collection<Task>]
  def costly_tasks_by_day = gateway.where('todo write sql ??? logic here')

  private

  # @return [Class<Task>]
  def gateway = Task
end
