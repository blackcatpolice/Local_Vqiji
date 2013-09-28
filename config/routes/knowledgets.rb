# encoding: utf-8

Weibo::Application.routes.draw do
  namespace :knowledge do
    resources :knowledges do
      collection do
        get :my
        get :groups
        get :widget
        get :popular
        get :latest
        get :search
      end
      
      member do
        put :pass_audit
        put :not_pass_audit
        put :publish
        put :draft
      end
      
      resources :comments, :only => [:create, :destroy] do
        member do
          get :reply_comments
          post :reply_comment
        end
      end
    end
    
    root to: 'knowledges#index'
  end
end
