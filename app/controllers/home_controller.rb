# encoding: utf-8

# 当前用户主页
class HomeController < WeiboController
  def show
    @feeds = current_user.feeds.includes(:tweet)
      .paginate(:page => params[:page], :per_page => 15)
    @tweets = @feeds.collect &:tweet
    # set_feeds_timeline if @feeds.current_page == 1
  end

  # 悄悄关注
  def whisper
    @feeds = current_user.feeds
      .where(:follow_type=>Followship::FOLLOW_TYPE_WHISPER)
      .paginate(:page => params[:page], :per_page => 15)
    @tweets = @feeds.collect &:tweet
  end
  
  # 特别关注
  def particular
    @feeds = current_user.feeds
      .where(:follow_type=>Followship::FOLLOW_TYPE_PARTICULAR)
      .paginate(:page => params[:page], :per_page => 15)
    @tweets = @feeds.collect &:tweet
  end
end
