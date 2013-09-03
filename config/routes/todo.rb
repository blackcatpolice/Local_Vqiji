Weibo::Application.routes.draw do
  namespace :todo do
  	resources :tasks, :only => [:show, :new, :create] do 
  		collection do 
      	get :mine
        get :myexecute
        get :mycreate
        get :finished 
        get :bycreate
        get :byexecute
        get :executors
        post :treeview
        post :progress
        post :my_tasks
    	end

    	member do 
        get :subs
        get :confirm
    	end

      resources :logs ,:only => [:index, :show, :new, :create, :destroy]
  	end # /tasks
  	
    #
    resources :counts do
      collection do
        get :mine 
      end
    end # /counts
  end # / namespace todo
end
