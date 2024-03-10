# frozen_string_literal: true

class BalancesUseCase
  include Aux::Pluggable

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] done_tasks_repository
  #   @return [DoneTasksRepository]
  resolve :done_tasks_repository
  # @!attribute [r] balances_repository
  #   @return [BalancesRepository]
  resolve :balances_repository

  # @param event_name   [BillingsConsumer::EARNED_EVENT_NAME, BillingsConsumer::DEDUCTED_EVENT_NAME]
  # @param billing_data [Hash]
  #   @key cost                 [Float]
  #   @key assignee_public_uid  [String]
  #   @key task_public_uid      [String]
  #   @key event_time           [String]
  # rubocop:disable Metrics/AbcSize
  def write(event_name, billing_data)
    top_management = users_repository.find_by(admin: true)
    popug          = users_repository.find_by(public_uid: billing_data[:assignee_public_uid])

    top_management_current = balances_repository.last_record(top_management).current
    popug_current          = balances_repository.last_record(popug).current

    case event_name
    when BillingsConsumer::EARNED_EVENT_NAME
      top_management_current += billing_data[:cost]
      popug_current          -= billing_data[:cost]
    when BillingsConsumer::DEDUCTED_EVENT_NAME
      top_management_current -= billing_data[:cost]
      popug_current          += billing_data[:cost]

      done_tasks_repository.create!(public_uid: billing_data[:task_public_uid], cost: billing_data[:cost])
    end

    balances_repository.create!(user_id: top_management.id, current: top_management_current,
                                time: billing_data[:event_time])
    balances_repository.create!(user_id: popug.id, current: popug_current, time: billing_data[:event_time])
  end
  # rubocop:enable Metrics/AbcSize
end
