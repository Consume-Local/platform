Rails.application.routes.draw do
  resources :listings
  devise_for :users
  root 'pages#index' # TODO: Replace this with listings index 
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
