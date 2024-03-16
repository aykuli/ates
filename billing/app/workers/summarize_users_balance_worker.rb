# frozen_string_literal: true

class SummarizeUsersBalanceWorker
  include Sidekiq::Worker
  include Aux::Pluggable

  sidekiq_options retry: false

  register initialize: true, memoize: true

  # @!attribute [r] users_repository
  #   @return [UsersRepository]
  resolve :users_repository
  # @!attribute [r] states_repository
  #   @return [StatesRepository]
  resolve :states_repository

  def perform
    byebug

    users = users_repository.all
    byebug

    users.find_each do
      todays_sum = count_day_earn(_1)

      _1.events.create!(
        state: states_repository.find_by(code: AccountStates::SUMMARIZED),
        cost: todays_sum
      )

      if todays_sum.positive?
        # TODO: sent money to popug
        _1.events.create!(
          state: states_repository.find_by(code: AccountStates::SENT),
          cost: todays_sum
        )
      end
    end
  end

  private

  # @param user [User]
  def count_day_earn(user)
    byebug
    sum = 0
    yesterday_sent_event = events_repository.where(user_id: user.id,
                                                   state_id: states_repository.find_by(code: AccountStates::SENT).id, created_at: Time.zone.now.yesterday)
    byebug
    if yesterday_sent_event.nil?
      yesterday_summarize_event = events_repository.where(user_id: user.id,
                                                          state_id: states_repository.find_by(code: AccountStates::SUMMARIZED).id, created_at: Time.zone.now.yesterday)
      byebug
      sum = yesterday_summarize_event.cost
    end

    todays_events = events_repository.where(user_id: user.id, created_at: Time.zone.now.all_day)

    todays_events.find_each do
      case _1.state.code
      when AccountStates::EARNED
        sum += _1.cost
      when AccountStates::DEDUCTED
        sum -= _1.cost
      end
    end

    sum
  end
end
