Rails.application.routes.draw do
  devise_for :users

  # Healthcheck for load balancers / uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  # CSP violation reports from browsers
  post "csp_violations", to: "csp_violations#create"

  # External SSO — JWT-based login from a third-party customer auth system.
  # Tenant's secret/claims живут в company.sso_*. См. ExternalSso.
  get "sso", to: "external_sso#callback", as: :external_sso

  resources :tickets, only: %i[index show new create] do
    member do
      post :transition
    end
  end

  root "tickets#index"
end
