Rails.application.routes.draw do
  scope "(:locale)", locale: /ru|en|de/ do
    devise_for :users

    get "sso", to: "external_sso#callback", as: :external_sso

    resources :tickets, only: %i[index show new create] do
      member do
        post :transition
        post :assign
      end
      resources :comments, only: %i[create], controller: "ticket_comments"
      resources :messages, only: %i[create], controller: "conversation_messages"
    end

    resources :invoices, only: %i[index show new create edit update]
    resources :notifications, only: %i[index] do
      collection { post :mark_read }
    end
    resources :ticket_types
    resources :users
    resources :customers, controller: "customers"

    namespace :settings do
      root to: "generals#show"
      resource  :general,       only: %i[show update], controller: "generals"
      resource  :ai,            only: %i[show update], controller: "ais"
      resource  :notification,  only: %i[show update], controller: "notifications"
      resource  :sso,           only: %i[show update], controller: "ssos"
      resource  :api_token,     only: %i[show],        controller: "api_tokens"
      resource  :payment,       only: %i[show update], controller: "payments"
      resource  :chat,          only: %i[show update], controller: "chats"
      resources :knowledge_articles
      resources :price_lists
    end

    root "tickets#index"
  end

  get  "up"             => "rails/health#show", as: :rails_health_check
  post "csp_violations" => "csp_violations#create"
end
