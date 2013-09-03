# encoding: utf-8

Weibo::Application.routes.draw do
  namespace :settings do
    resource :basic, only: [:show], controller: 'basic'
    
    resource :avatar, only: [:edit], controller: 'avatar' do
      get 'show' => :edit
      post 'update' => :octet_stream_update
    end
    
    resource :password, only: [:edit, :update], controller: 'password' do
      get 'show' => :edit
    end
    
    root :to => 'basic#show'
  end
end
