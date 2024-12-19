Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController
  
  post "/graphql", to: "graphql#execute"
  
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: "/graphql" if Rails.env.development?

  root 'users#index'

  namespace :api do
    post 'users/:id/set_status', to: 'users#set_status'
    post 'users/:id/set_bonus', to: 'users#set_bonus'
    post 'users/mail_all', to: 'users#mail_all'
    resources :users, only: [:index, :show]

    resources :categories

    resources :vacancies, only: [:index, :create]
  end
end
