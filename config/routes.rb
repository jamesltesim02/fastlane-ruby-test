Rails.application.routes.draw do
  get 'welcome/index'
  get 'welcome/mview'
  post 'welcome/receive'
  get 'welcome/result'
  get 'welcome/appid'
  get 'welcome/:config', to: 'welcome#udid'

  resources :articles

  root 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
