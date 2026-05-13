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
      resource :ai_actions, only: [], controller: "ai_actions" do
        post :suggest_reply
        post :categorize
        post :summarize
        post :sentiment
      end
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
      resources :languages, controller: "languages" do
        member do
          post :set_default
          post :toggle
        end
      end
      resources :knowledge_articles
      resources :price_lists do
        resources :price_items, only: %i[create update destroy], controller: "price_items"
      end
    end

    root "tickets#index"
  end

  get  "up"             => "rails/health#show", as: :rails_health_check
  post "csp_violations" => "csp_violations#create"
end
