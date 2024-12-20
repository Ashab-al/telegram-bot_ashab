Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController
  
  post "/graphql", to: "graphql#execute"
  
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: "/graphql" if Rails.env.development?

  root 'users#index'

  namespace :api do
    post 'users/mail_all', to: 'users#mail_all'
    resources :users, only: [:index, :show] do 
      member do 
        post 'set_status'
        post 'set_bonus'
      end
    end

    resources :categories

    resources :vacancies, only: [:index, :create]
  end
end
