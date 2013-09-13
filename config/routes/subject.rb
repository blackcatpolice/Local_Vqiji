# encoding: utf-8
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
