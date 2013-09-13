# encoding: utf-8
Weibo::Application.routes.draw do
  resources :network_disks, :only => [:index] do 
    collection do
      get  :swfupload, :path => "swfupload.html"
      get  :swfupload_widget, :path => "w_swfupload.html"
      get  :history, :path => "history.html"
      get  :share, :path => "share.html" 
      get  :message, :path => "message.html"
      post :upload
      post :collect
      post :rename
      post :encrypt
      post :destroy_list
    end
    
    get :download
  end
end
