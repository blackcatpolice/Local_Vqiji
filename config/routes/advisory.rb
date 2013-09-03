Weibo::Application.routes.draw do
  namespace :advisory do
    resources :questions, :only => [:show, :destroy, :create] do
      get "solved", :on => :collection
      get "unsolved", :on => :collection
    end

    post "questions/:id/solve" => "questions#solve_question"

    resources :experts, :only => [:show, :update] do
      get "solved", :on => :collection
      get "unsolved", :on => :collection
    end
    
    resources :answers, :only => [:create]
  end
  
  get 'advisory/:id' => "advisory/question_types#show"
end
