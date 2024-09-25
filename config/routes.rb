Rails.application.routes.draw do
  root to: "pages#index"
  get "pages/secret"
  resources :user_sessions, only: [:new, :create]
  resources :users, only: [:index, :new, :create]
end
