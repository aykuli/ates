# frozen_string_literal: true

class TasksUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] states_repository
  #   @return [StatesRepository]
  resolve :states_repository
  # @!attribute [r] repository
  #   @return [TasksRepository]
  resolve :tasks_repository, as: :repository
  # @!attribute [r] producer
  #   @return [BillingsProducer]
  resolve :billings_producer, as: :producer
  # @!method logger
  #   @return [Recorder::Agent]
  # resolve :logger

  # @param task_data        [Hash]
  #   @key task_public_uid  [String]
  #   @key user_public_uid  [String]
  #   @key task_title       [String]
  #   @key jira_id          [String]
  #   @key state            [String]
  def create(task_data)
    task = repository.find_by(public_uid: task_data[:public_uid])
    return if task

    repository.create_as_consumer!(
      user_public_uid: task_data[:user_public_uid],
      public_uid: task_data[:public_uid],
      title: task_data[:title],
      jira_id: task_data[:jira_id],
      updated_at: task_data[:updated_at],
      state: 'created'
    )

    # logger.info(message: 'Task was created',
    #             producer: "BillingsUseCase.create",
    #             payload: task_data.to_s) unless task
  end
end
