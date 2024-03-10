Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get 'auth/:provider/callback', to: 'sessions#create'
  get "/login", to: 'sessions#new'
  post "logout", to: 'sessions#destroy'

  root to: "tasks#index"

  post 'tasks', to: 'tasks#filter'
  post 'tasks/create', to: 'tasks#create'
  post 'tasks/reassign', to: 'tasks#reassign'
  post 'tasks/complete', to: 'tasks#complete'
  get 'tasks/error', to: 'tasks#error'
end
