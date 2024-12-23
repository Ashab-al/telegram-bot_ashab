Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController
  
  post "/graphql", to: "graphql#execute"
  
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: "/graphql" if Rails.env.development?

  root 'users#index'

  

  resources :users#, except: [:delete]
  # resources :categories

  namespace :api do
    resource :vacancy, only: [:create, :index]
  end
end
