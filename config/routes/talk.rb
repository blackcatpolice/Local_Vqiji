Weibo::Application.routes.draw do
  namespace :talk do
    resources :sessions, only: [:index, :show, :destroy, :create] do
      resources :members, only: [:index, :destroy] do
        post :add, on: :collection
      end
      
      resources :messages, only: [:index, :create, :show, :destroy], shallow: true do
        post 'rt_create', on: :collection
        
        collection do
          get 'unread_count'
          get 'unreads'
          post 'reset_unread_count'
        end
      end
      
      post 'make_current', on: :member
      
      collection do
        delete 'clear_current'
        
        get 'pull'
        get 'fetch'
      end
    end

    namespace :messages do
      get 'to_u/:user_id/new_modal', to: :new_modal_to_user
      post 'to_u/:user_id', to: :create_to_user
      post 'to_user/by_name', to: :create_to_user_by_name
    end

    match '/' => 'sessions#index', via: :get
  end
end
