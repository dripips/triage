Rails.application.routes.draw do
  devise_for :users

  # Healthcheck for load balancers / uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  # CSP violation reports from browsers
  post "csp_violations", to: "csp_violations#create"

  root "welcome#show"
end
