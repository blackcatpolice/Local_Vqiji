# encoding: utf-8

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
