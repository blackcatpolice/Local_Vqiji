# encoding: utf-8

# 提到当前用户微博
module My
  class Mention::TweetsController < MentionsController
    # 获取提到当前用户的微博
    def index
      @tweets = Tweet.at_user(current_user.id)
      @tweets = @tweets.to_fans if(params[:hall] && params[:hall].to_i == 1)
      @tweets = @tweets.where(:group_ids => params[:group]) unless params[:group].blank?
      @tweets = @tweets.paginate(:page => params[:page], :per_page => 20)
      
      render
      current_user.notification.reset!(Notification::TweetMention)
    end
  end  
end
