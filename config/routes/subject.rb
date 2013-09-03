# encoding: utf-8
# 工作组相关路由

Weibo::Application.routes.draw do
  
  namespace :blog do
    match '/' => 'subjects#index'
  	resources :subjects do
  		member do 
  			get :spheres
  		end
  	end
  end  
  
end
