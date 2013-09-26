# encoding: utf-8

Weibo::Application.routes.draw do
  namespace :knowledge do
    resources :knowledges do
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
      resources :comments do
        member do
          get :reply_comments
          post :reply_comment
        end
      end
    end
  end
end
