Rails.application.routes.draw do
  get 'users/index'
  get 'users/show'
  get 'users/edit'
  get 'users/update'
  get 'users/destroy'
  root 'users#index'

  telegram_webhook TelegramWebhooksController
end
