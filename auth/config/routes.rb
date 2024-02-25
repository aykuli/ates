Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: {
    sessions: 'user/sessions'
  }

  get "up" => "rails/health#show", as: :rails_health_check
end
