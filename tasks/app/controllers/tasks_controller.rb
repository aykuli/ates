# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authenticate

  def index
    session[:errors] = nil
    @tasks = tasks_use_case.filter(current_user).payload
  end

  def error
    @errors = session[:errors]
  end

  def create # rubocop:disable Metrics/AbcSize
    result = tasks_use_case.create_the_assign!(params, current_user)

    if result.failed?
      session[:errors] = result.errors

      redirect_to tasks_error_path
    else
      task = result.payload
      produce_next = tasks_producer.produce_async(task, States::CREATED, version: 2)

      if produce_next
        tasks_producer.produce_async(task, States::ASSIGNED)
      else
        session[:errors] =
          "Billing dont know who is the assignee of task with id = #{task.id} with public_id = #{task.public_uid}"
      end

      redirect_to root_path
    end
  end

  def reassign
    result = tasks_use_case.reassign!(current_user)

    tasks_producer.produce_many_async(result.payload, States::REASSIGNED)

    redirect_to root_path
  end

  def complete
    result = tasks_use_case.complete!(params)

    if result.failed?
      session[:errors] = result.errors

      redirect_to tasks_error_path
    else
      tasks_producer.produce_async(result.payload, States::COMPLETED)
    end

    redirect_to root_path
  end
end
