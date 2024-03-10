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

  def create
    result = tasks_use_case.create!(params, current_user)

    if result.failed?
      session[:errors] = result.errors

      redirect_to tasks_error_path
    else
      tasks_producer.produce_async(result.payload, version: 2)

      redirect_to root_path
    end
  end

  def reassign
    result = tasks_use_case.reassign!(current_user)

    tasks_producer.produce_many_async(result.payload, version: 1)

    redirect_to root_path
  end

  def complete
    result = tasks_use_case.complete!(params)

    if result.failed?
      session[:errors] = result.errors

      redirect_to tasks_error_path
    else
      tasks_producer.produce_async(result.payload, version: 1)
    end

    redirect_to root_path
  end
end
