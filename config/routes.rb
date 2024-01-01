Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController

  root 'users#index'
  resources :users#, except: [:delete]
  resources :categories
end
