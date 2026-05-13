Rails.application.routes.draw do
  scope "(:locale)", locale: /ru|en|de/ do
    devise_for :users

    # External SSO — JWT-based login from a third-party customer auth system.
    get "sso", to: "external_sso#callback", as: :external_sso

    resources :tickets, only: %i[index show new create] do
      member { post :transition }
      resources :comments, only: %i[create], controller: "ticket_comments"
    end

    resources :ticket_types
    resources :users
    resources :customers, controller: "customers"

    root "tickets#index"
  end

  # Locale-free utility endpoints.
  get  "up"             => "rails/health#show", as: :rails_health_check
  post "csp_violations" => "csp_violations#create"
end
