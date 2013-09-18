# encoding: utf-8

Weibo::Application.routes.draw do
  resources :knowledges, :except => [:destroy] do
    collection do
      get :my
      get :groups
      post :delete
      get :widget
    end
    member do
      get :content
    end
  end
end
