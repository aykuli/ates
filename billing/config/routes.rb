Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get 'auth/:provider/callback', to: 'sessions#create'
  get "/login", to: 'sessions#new'
  post "logout", to: 'sessions#destroy'

  root to: "events#index"
end
