# encoding: utf-8

Weibo::Application.routes.draw do
  namespace :widgets do
    get 'weather/t'
  end
end
