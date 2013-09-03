# encoding: utf-8
# 商城相关路由

Weibo::Application.routes.draw do
 
  namespace :store do
    ###########
    ##前端路由，全部访问 Store::StoreContoller控制器
    ##########
    get '/' => 'products#index'
    get '/:id.html' => 'products#show' #商品详细
    get '/:id.shtml' => 'order_items#show' #商品快照 
   
    #
    resources :invoices,:only => [:index,:create,:show] do
      collection do 
   		   match '/new' => 'invoices#new'
   		 end
    end
    #
    resources :orders,:only => [:index,:show,:edit] do
       member do
          get :delete
       end 
    end
   # match 'orders/:id/destroy' => 'orders#destroy'
    
    resources :products,:only => [:index] do
      collection do 
   		   get '/unexchange' => 'products#unexchange'
   		 end
    end
    match 'orders/:id/success.html' => 'orders#success'
    match 'orders/:id/submit' => 'orders#submit' 
    match 'orders/:id/confirm' => 'orders#confirm' 
    match 'orders/:id/destroy' => 'orders#destroy'
    #购物车相关
    match 'cart' => 'cart#index'
    match 'cart/put' => 'cart#put'
    match 'cart/update' => 'cart#update'
    match 'cart/remove/:k' => 'cart#remove'
    match 'cart/removes' => 'cart#removes'
    match 'cart/checkout' => 'cart#checkout'
    #
    #get 'my/orders' => 'my#orders'
    #get 'my/orders/:id' => 'my#show_order'
    #get 'my/orders/:id/edit' => 'my#edit_order'
    #get 'my/orders/:id/destroy' => 'my#destroy_order'
    #match 'my/orders/:id/submit' => 'my#submit_order' 
    #match 'my/orders/:id/confirm' => 'my#confirm_order' 
    
  end
end
