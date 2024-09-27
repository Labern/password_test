Rails.application.routes.draw do
  root to: "pages#index"
  get "pages/secret"
  resources :user_sessions, only: [:new, :create, :destroy]
  resources :users, only: [:index, :new, :create]
end
