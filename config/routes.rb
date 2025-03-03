Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController

  namespace :api do
    post 'users/mail_all', to: 'users#mail_all'
    resources :users, only: %i[index show] do
      member do
        post 'set_status'
        post 'set_bonus'
      end
    end

    resources :categories

    resources :vacancies, only: %i[index create]
  end
end
