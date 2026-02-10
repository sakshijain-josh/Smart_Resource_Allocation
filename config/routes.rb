Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Root level swagger access
  get "swagger.yaml", to: "api/v1/documentation#index", defaults: { format: "yaml" }

  # API routes
  namespace :api do
    namespace :v1 do
      # Devise authentication routes
      devise_for :users,
                 skip: [ :registrations, :passwords, :confirmations, :unlocks ],
                 path: "",
                 path_names: {
                   sign_in: "auth/login",
                   sign_out: "auth/logout"
                 },
                 controllers: {
                   sessions: "api/v1/sessions"
                 }

      # Custom route for current user
      devise_scope :user do
        get "auth/me", to: "registrations#show"
      end

      # Admin-only user management
      resources :users, only: [ :create, :index, :destroy ]

      # Resource management
      resources :resources do
        member do
          get :availability
        end
      end
      resources :bookings do
        collection do
          post :release_expired
        end
        member do
          post :check_in
        end
      end
      # Reports
      namespace :reports do
        get :resource_usage
        get :user_bookings
        get :peak_hours
        get :utilization
      end
    end
  end
end
