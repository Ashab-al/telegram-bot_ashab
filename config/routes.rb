Rails.application.routes.draw do
  telegram_webhook TelegramWebhooksController
  
  post "/graphql", to: "graphql#execute"
  
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: "/graphql" if Rails.env.development?

  root 'users#index'

  

  resources :users#, except: [:delete]
  # resources :categories

  namespace :api do
    match 'vacancies_create', to: 'vacancy#create', via: [:post, :get]
    match 'get_all_vacancies', to: 'vacancy#index', via: [:get]
    namespace :vpn do
      match 'login', to: 'vpn#vpn_login', via: [:post]
      match 'inbounds_list', to: 'vpn#inbounds_list', via: [:post]
    end
  end
end
