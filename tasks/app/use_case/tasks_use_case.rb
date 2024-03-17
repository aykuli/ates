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
  # @!attribute [r] producer
  #   @return [TasksProducer]
  resolve :tasks_producer, as: :producer

  # @param user [User]
  # @return     [SuccessCarrier]
  def filter(user)
    tasks = user.admin? ? repository.all : repository.filter(assignee_id: user.id)
    success(tasks.order(created_at: :asc))
  end

  # @param params [ActionController::Parameters]
  # @param user [User]
  # @return [SuccessCarrier, FailureCarrier]
  def create_the_assign!(params, user)
    attributes = extract_title_jira_id(params)
    return failure(:unprocessable_entity, { message: 'Wrong attributes' }) if attributes.nil?

    task = repository.create!(title: attributes[:title], jira_id: attributes[:jira_id])
    return failure(:unprocessable_entity, { message: 'Cannot create task' }) unless task

    ActiveRecord::Base.transaction do
      create_event!(task, States::CREATED, user:)
      find_assignee!(task, States::ASSIGNED, user)
    end

    success(task)
  end

  # @param user [User]
  # @return     [SuccessCarrier]
  def reassign!(user)
    tasks = repository.filter(state: [States::ASSIGNED, States::REASSIGNED])
    tasks.find_each { find_assignee!(_1, States::REASSIGNED, user) }

    success(task)
  end

  # @param params [ActionController::Parameters]
  # @return [SuccessCarrier, FailureCarrier]
  def complete!(params)
    task = repository.find_by(id: params[:id])
    return failure(:unprocessable_entity, { message: 'No such task' }) unless task

    create_event!(task, States::COMPLETED, user: task.assignee)

    success(task)
  end

  private

  # @param task       [Task]
  # @param state_code [String]
  # @param user       [User]
  def find_assignee!(task, state_code, user)
    rand_user = users_repository.take_random
    create_event!(task, state_code, user:, assignee: rand_user)
  end

  # @param task       [Task]
  # @param state_code [String]
  #   @key user       [User]
  #   @key assignee   [User]
  def create_event!(task, state_code, user:, assignee: nil)
    task.events.create!(
      state: states_repository.find_by(code: state_code),
      user_id: user.id,
      assignee_id: assignee&.id
    )
  end

  # @param params [ActionController::Parameters]
  # @return [Hash<title, jira_id>]
  def extract_title_jira_id(params)
    jira_regexp = /\[[a-zа-яА-ЯA-Z1-9]+\]/
    title_regexp = /[^а-яА-Яa-zA-Z1-9]+/
    jira_id = params[:title].match(jira_regexp)
    jira_txt = jira_id.nil? ? nil : jira_id[0]
    jira_id = jira_txt.nil? ? nil : jira_txt[1..jira_txt.size - 2]
    split = params[:title].split(jira_regexp, 2)

    return unless split.size == 2

    { title: split[1].gsub(title_regexp, ''), jira_id: }
  end
end
