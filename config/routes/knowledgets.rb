# encoding: utf-8

Weibo::Application.routes.draw do
  namespace :knowledge do
    resources :knowledges, :except => [:destroy] do
      collection do
        get :my
        get :groups
        post :delete
        get :widget
        get :popular
        get :latest
        get :search
      end
      member do
        get :content
        put :check
      end
      resources :comments
    end

    resources :knowledge_collections do
    end
  end
end
