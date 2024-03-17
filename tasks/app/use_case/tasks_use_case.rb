# frozen_string_literal: true

class TasksUseCase
  include Aux::Pluggable
  include DIY::Carrierable

  register initialize: true, memoize: true

  # @!attribute [r] repository
  #   @return [TasksRepository]
  resolve :tasks_repository, as: :repository
  # @!attribute [r] states_repository
  #   @return [StatesRepository]
  resolve :states_repository
  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository

  # @param user [User]
  # @return     [SuccessCarrier]
  def filter(user)
    tasks = user.admin? ? repository.all : repository.filter(assignee_id: user.id)
    success(tasks.order(created_at: :asc))
  end

  # @param params [ActionController::Parameters]
  # @param user   [User]
  # @return       [SuccessCarrier]
  def create!(params, user)
    task = repository.create!(title: params[:title])
    return failure(:unprocessable_entity) unless task

    ActiveRecord::Base.transaction do
      create_event(task, States::CREATED, user:)
      find_assignee!(task, States::ASSIGNED, user)
    end

    success(task)
  end

  # @param user [User]
  # @return     [SuccessCarrier]
  def reassign!(user)
    tasks = repository.filter(state: [States::ASSIGNED, States::REASSIGNED])
    tasks.find_each { find_assignee!(_1, States::REASSIGNED, user) }

    success(tasks)
  end

  # @param params [ActionController::Parameters]
  # @return       [SuccessCarrier]
  def complete!(params)
    task = repository.find_by(id: params[:id])
    return failure(:unprocessable_entity) unless task

    create_event(task, States::DONE, user: task.assignee)

    success(task)
  end

  private

  # @param task       [Task]
  # @param state_code [String]
  # @param user       [User]
  def find_assignee!(task, state_code, user)
    rand_user = users_repository.take_random
    create_event(task, state_code, user:, assignee: rand_user)
  end

  # @param task       [Task]
  # @param state_code [String]
  #   @key user       [User]
  #   @key assignee   [User]
  def create_event(task, state_code, user:, assignee: nil)
    task.events.create!(
      state: states_repository.find_by(code: state_code),
      user_id: user.id,
      assignee_id: assignee&.id
    )
  end
end
