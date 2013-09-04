Weibo::Application.routes.draw do
  namespace :meeting do
    resources :meetings do 
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

    resources :members ,:controller => "meeting_members" do
      collection do
        get  :search
        get  :list
        match :save
      end
    end

    end # /tasks
  end # / namespace todo
end
