# frozen_string_literal: true

class DoneTasksRepository
  include Aux::Pluggable

  register initialize: true, memoize: true

  def costly_tasks_by_day = gateway.where('todo write sql ??? logic here')

  private

  # @return [Class<User>]
  def gateway = DoneTask
end
