# encoding: utf-8
# 人事相关路由

Weibo::Application.routes.draw do
   namespace :hr do
    get '/' => 'home#index'
   end
end
