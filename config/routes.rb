Rails.application.routes.draw do
  devise_for :users
  root 'pages#index'

  get '/guias', to: 'pages#guides'
end
