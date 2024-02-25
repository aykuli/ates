Rails.application.routes.draw do
  root to: 'users#index'

  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  get '/accounts/current', to: 'accounts#current'
end
