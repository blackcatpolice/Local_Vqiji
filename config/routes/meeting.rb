Weibo::Application.routes.draw do
  namespace :meeting do
    resources :meetings do 
      collection do 
        get :recently
        get :launched
        get :invited
      end

      member do 
        # get :subs
        # get :confirm
      end

    resources :members , :controller => "meeting_members", :only => [:index, :show, :edit] do
      collection do
        get :search
        get :list
        put :change_status
        match :save
      end
    end

    end # /tasks
  end # / namespace todo
end
