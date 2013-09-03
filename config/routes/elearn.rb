# encoding: utf-8
# 在线培训相关路由

Weibo::Application.routes.draw do
#
namespace :elearn  do
  resources :trainings,:only => [:index,:show] do
    collection do
        get  :unstart #未开始
        get  :unfinished #未完成
        get  :unexam #未考试
        get  :uncheck #未检测
        get  :unpass #未通过
        get  :pass #通过
        #get  :my
      end
    member do 
			 get :start #开始
			 get :restart #重新学习
			 get :reset #重置进度
			 get :result #查看结果
			 #match :go_on
		end #member end
		resources :pages,:only => [:index,:show] do
		    member do
		      post :next
		      get  :study
		    end
		end# pages end
		resources :tests,:only => [:index] do
		  collection do
		    match :check 
		  end
		end
  end
  
  
end
#
  
end
