Weibo::Application.routes.draw do
  devise_for :users, :path => '/'

  # 注册/登录/登出
  get 'sign_in'  => 'devise/sessions#new'
  get 'sign_out' => 'devise/sessions#destroy'
  get 'sign_up' => 'checks#new'

  devise_scope :users do
    resources :checks , :only => [ :new, :create ]
    resources :registrations, :only => [ :new, :create ]
  end

  # 我的微博
  namespace :my do
   	match 'medicals/:id/destroy' => 'medicals#destroy' 
    resources :medicals do 
  		collection do 
  			post "destroy_batch"
  			get "my_medicals"
  		end
  		post :changetitle, :on => :member
  	end
    
    # 提到
    namespace :mention do
      resources :tweets, :only => [:index]
      resources :comments, :only => [:index]
    end
    
    # 关注
    resources :followeds, :only => [:create, :destroy] do
      get :query,:on => :collection
    end
    
    # 收藏
    resources :favorites, :only => [:index, :create, :destroy]
    
    # 收到的微博
    resources :feeds, :only => [:index] do
      match 'news', :on => :collection
    end
    
    # 评论
    resources :comments, :only => [] do
      collection do
        get :sends
        get :receives
      end
    end
  end # /namespace :my

  resource :home, :only => [:show], :controller => 'home' do
    get :particular
    get :whisper
  end # /resource :home
  
  resources :notifications, :only => [:index] do
    get :count, :on => :collection
    get :nb, :on => :collection
  end
  
  # 用户相关
  resources :users, :only => [:show]  do
    member do
      get :followeds
      get :fans
      get :card
    end

    match 'search', :on => :collection
  end

  # 微博发送/删除
  resources :tweets, :only => [:show, :create, :destroy], :shallow => true do
    scope :module => 'tweet' do
      resources :reposts, :only  => [:index, :new, :create]
      resources :comments, :only => [:index, :show, :new, :create, :destroy] do
    		get :list, on: :collection
      end
    end
  end

  # 话题
  resources :topics, :only => [:show]

  resources :departments, :only => [:index] do
    get :flat, on: :collection
    get :cell, on: :collection
    get 'members' => 'departments#members', on: :member
  end

  # 工作组相关
  resources :groups, :except => [:destroy] do 
	  collection do
		  match :gets
		  get :list
		  get :mine
	  end

    get :tops, on: :member
	
	  resources :members ,:controller => "group_members" do
      collection do
        get  :search
        get  :list
        match :save
      end

      member do
        get :set_admin
        get :cancel_admin
        get :quit
        match :delete
      end
  	end
  end # /resources :groups
  
  #制度
  resources :rules, :only => [:index,:show] do 
  	get :read, :on => :member
  	get :search, :on => :collection
  	get :visible, :on => :member
  end
  
  resources :formalitity, :only => [:index,:show]
  
  resources :tests do 
  	get :list, :on => :collection
  end

  # 附件
  resources :attachments, :only => [:index, :destroy] do
    collection do
      post :file
      post :audio
      post :picture
      post :history
      post :disks
      post :kindsoft_picture
      get :case_history
    end
  end

  match 'tmp/audios'  => 'attachments#audio'
  get 'download/:id' => 'attachments#download', as: :download_attachment

  # 短链接
  resources :urls, :only => [] do
    match 'shorten', :on => :collection
    match 'expand',  :on => :collection
    match 'valid_video_url', :on => :collection
  end

  # 城市
  get 'cities' => 'cities#index'

  root :to => 'home#show'
  
  # !!! NEVER, NEVER & NEVER enable this!
  # match ':controller(/:action(/:id(.:format)))'
end
