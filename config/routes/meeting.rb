Weibo::Application.routes.draw do
  namespace :meeting do
    resources :meetings, :only => [:index, :show, :new, :create] do 
      collection do 
        # get :mine
        # get :myexecute
        # get :mycreate
        # get :finished 
        # get :bycreate
        # get :byexecute
        # get :executors
        # post :treeview
        # post :progress
        # post :my_tasks
      end

      member do 
        # get :subs
        # get :confirm
      end

    end # /tasks
  end # / namespace todo
end
