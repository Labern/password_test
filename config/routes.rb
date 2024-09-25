Rails.application.routes.draw do
  root to: "users#index"
  resources :users, only: [:index, :new, :create]
end
