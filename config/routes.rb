Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController
  
  post "/graphql", to: "graphql#execute"
  
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: "/graphql" if Rails.env.development?

  root 'users#index'

  namespace :api do
    resources :users, except: [:delete]
    resources :categories, only: [:create, :update, :destroy]
    resource :vacancy, only: [:create, :index]
  end
end
