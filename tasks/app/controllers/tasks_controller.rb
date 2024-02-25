# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :authenticate

  def index
    @tasks = tasks_use_case.filter(current_user).payload
  end

  def create
    result = tasks_use_case.create!(params, current_user)

    tasks_producer.produce_async(result.payload)

    redirect_to root_path
  end

  def reassign
    result = tasks_use_case.reassign!(current_user)

    tasks_producer.produce_many_async(result.payload)

    redirect_to root_path
  end

  def complete
    result = tasks_use_case.complete!(params)

    tasks_producer.produce_async(result.payload)

    redirect_to root_path
  end
end
