Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  require "sidekiq/web"
  # Optionally secure with basic auth in production
  mount Sidekiq::Web => "/sidekiq"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # NOTE: Following Zalando's guidelines, we will omit "/api/v1"
  resources :categories # , only: [:index, :show, :create, :update, :destroy]

  # Authentication
  post "auth/login", to: "auth#login"

  # Reports
  get "reports/top-products-by-category", to: "reports#top_products_by_category"
  get "reports/top-revenue-products-by-category", to: "reports#top_revenue_products_by_category"

    # Purchases listing with filters
    resources :purchases, only: [ :index ] do
      collection do
        get :counts
      end
    end
end
