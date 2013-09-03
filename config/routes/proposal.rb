# encoding: utf-8
# 工作组相关路由

Weibo::Application.routes.draw do
  
  namespace :proposal do
  	resources :suggests do
  		collection do
  			get	:checking
  			get :checked
  			get :refuse
  		end
  	
  	end
  	
  	resources :comments
  end  
  
end
