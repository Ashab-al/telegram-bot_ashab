Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController

  root 'users#index'
  resources :users#, except: [:delete]
  resources :categories

  namespace :api do
    match 'vacancies_create', to: 'vacancy#create', via: [:post, :get]
    match 'ykassa_callback', to: 'yandex_kassa_callback#index', via: [:post, :get]
  end
end
