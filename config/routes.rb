Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: "/graphql"
    
    root to: redirect('/graphiql')
  else 
    root 'users#index'
  end

  telegram_webhook TelegramWebhooksController

  
  resources :users#, except: [:delete]
  # resources :categories

  namespace :api do
    match 'vacancies_create', to: 'vacancy#create', via: [:post, :get]
    match 'get_all_vacancies', to: 'vacancy#index', via: [:get]
    match 'ykassa_callback', to: 'yandex_kassa_callback#index', via: [:post, :get]
  end
end
