# frozen_string_literal: true

Rails.application.routes.draw do
  root 'users#index'

  use_doorkeeper

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  get '/users/current', to: 'users#current'

  get "/users/:id/edit",    to: "users#edit", as: :edit_user
  post "/users/:id/update", to: 'users#update', as: :update_user
end
