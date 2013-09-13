# encoding: utf-8
# 商城相关路由

Weibo::Application.routes.draw do
  namespace :admin  do
    resources :attachments, :only => [:index]
    resources :companies,:only => [:index] do 
      collection do 
      end
    end
    
    #部门 
    resources :departments,:only => [:index,:show,:new,:create,:destroy] do
      collection do
        get :home
        get :list
        get :gets
        get :search
      end
    end
    
    #工作组
	  resources :groups,:only => [:index,:show,:new,:create,:edit,:update,:destroy] do
      collection do
        get :home
        get :search
      end
       member do
        get :base
      end
      resources :members ,:controller => "group_members" do
        collection do
          get  :search
          match :save
        end
         member do
          get :set_admin
          get :cancel_admin
        end
      end
    end
    #用户
    resources :users,:only => [:index,:show,:new,:create,:edit,:update] do
      collection do
        get :home
        get :search
        get :gets
      end
    end
    
 	  #----------------------------------------------------------------
    
    namespace :elearning  do
      resources :types      #
      resources :trainings do
        resources :pages
        resources :tests
        #
        resources :users do
          collection do
            match :save
          end
          member do
            get :result #显示结果
            post :score #评分
          end
        end
        
        member do 
 				 get :start
 				 get :release
 				 get :cancel
   			end
        collection do 
          get :home
        end
        #     
      end
      # match 'trainings/:training_id/pages/:id/destroy' => 'pages#destroy'
      # match 'trainings/:training_id/tests/:id/destroy' => 'tests#destroy'
      # match 'trainings/:training_id/users/:id/destroy' => 'users#destroy'
      match 'trainings/:id/destroy' => 'trainings#destroy'
    end # elearning end
   	
   	resources :excels,:only => [:index,:create,:show]
   	match 'excels/:id/import' => 'excels#import'
   	resources :employees,:only => [:index,:new,:create,:show,:edit]
   	
   	# match 'groups/:id/members' => 'groups#members'
   	# match 'groups/:id/members/set' => 'groups#members_set'
   	# post 'groups/:id/members/save' => 'groups#members_save'
   	# match 'groups/:id/members/:member_id/admin' => 'groups#members_admin'
   	# match 'groups/:id/members/:member_id/destroy' => 'groups#members_destroy'
    resources :products,:only => [:index,:new,:create,:show,:edit,:update] #:except=>[:destroy]
    resources :product_types,:only => [:index,:new,:create,:show,:edit,:update]
    
    resources :menus,:only => [:index,:new,:create,:show,:edit,:update]
    resources :admins,:only => [:index,:new,:create,:show,:edit,:update] do
    end
    
    put 'admins' => "admins#update"
    #---------------------------------------------------------
    resources :roles,:only => [:index,:new,:create,:show,:edit,:update]
    
    #    
    match 'roles/:id/destroy' => 'roles#destroy'
    match 'menus/:id/destroy' => 'menus#destroy'
    match 'admins/:id/destroy' => 'admins#destroy'
    match 'products/:id/destroy' => 'products#destroy'
    match 'product_/:id/destroy' => 'product_types#destroy'
    #put 'product_types' => 'product_types#update'
    match 'orders' => 'orders#index'
    match 'orders/count' => 'orders#count'
    match 'orders/:id/destroy' => 'orders#destroy'
    match 'orders/:id' => 'orders#show'
    match 'orders/:id/update' => 'orders#update'
    ##
    match 'invoices' => 'invoices#index'
    match 'invoices/hr' => 'invoices#hr'
    match 'invoices/dept' => 'invoices#dept'
    match 'invoices/website' => 'invoices#website'
    match 'invoices/:id/update' => 'invoices#update'
    
    
    match 'invoices/update_step/:id/:step' => 'invoices#update_step'
    match 'invoices/:id' => 'invoices#show'
    match 'invoices/:id/destroy' => 'invoices#destroy'
    
    #----------------------------------------------------------
	  resources :questions,:only=>[:index] do
    end
  
    match 'questions/:id/destroy' => 'questions#destroy' 		

    resources :experts do
     member do
       get :disable
     end
    end

    resources :question_types do
     member do
        get :disable
     end
     
    end


    match 'subjects/destroy/:id' => 'subjects#destroy'
    resources :subjects, :except => [:destroy] do
	    collection do
		    get :search
	    end
	    member do 
		    get :visible
	    end
    end

    match 'blognavs/:id/destroy' => 'blognavs#destroy'
    resources :blognavs, :except => [:destroy]

    match 'rules/destroy/:id' => 'rules#destroy'
    resources :rules do 
		    member do 
			    get :isvisible
		    end   
    end

    match 'proposals/destroy/:id' => 'proposals#destroy'   
    resources :proposals do
    member do
	    put :check
	    get :notcheck
    end
    end

    match 'formalitity/destroy/:id' => 'formalitity#destroy'
    resources :formalitity do 
    member do 
	    get :isvisible
    end
    end

    namespace :atype  do
     resources :blogtypes, :except => [:show] do 
       member do 
        get :view
       end
     end
     resources :qatypes, :except => [:show]
    end

    match 'rtypes/destroy/:id' => 'rtypes#destroy'
    resources :rtypes
    #---------------------weibo------------------------------------
    namespace :weibos  do
      get '/' => 'base#index'
      resources :tweets,:only => [:index] #
      match 'tweets/:id/destroy' => 'tweets#destroy'
    end

    resources :couriers,:only => [:index,:new,:edit,:create,:update]
    match 'couriers/destroy/:id' => 'couriers#destroy'

    resources :knowledge_types

    root :to => 'users#home'
  end
end
