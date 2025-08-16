Rails.application.routes.draw do
  namespace :api do
    # Authentication routes
    post 'auth/register', to: 'auth#register'
    post 'auth/login', to: 'auth#login'
    delete 'auth/logout', to: 'auth#logout'
    get 'auth/current_user', to: 'auth#current_user'

    # Public time slots and reviews
    resources :time_slots, only: [:index, :show]
    resources :reviews, only: [:index, :create, :update, :destroy]

    # User reservations
    resources :reservations, only: [:index, :show, :create, :update, :destroy]

    # Admin routes
    namespace :admin do
      resources :tables
      resources :time_slots, only: [:create, :update, :destroy]
      
      # Additional admin routes for reservations management
      resources :reservations, only: [:index, :show, :update] do
        member do
          patch :confirm
          patch :complete
        end
      end
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Root route
  root "rails/health#show"
end
