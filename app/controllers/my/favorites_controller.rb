# encoding: utf-8

# 当前用户收藏的微博
class My::FavoritesController < WeiboController

  # 查看收藏
  def index
    @favorites = current_user.favorites.includes(:tweet)
      .paginate(:page => params[:page], :per_page => 30)
    @tweets = @favorites.collect &:tweet
  end

  # 收藏微博
  #
  # == 参数：
  #  tweet_id: 微博 id
  #
  # 返回被收藏到微博到详细信息
  def create
    @tweet = Tweet.find(params[:tweet_id])
    current_user.favorite(@tweet)
    render :json => true
  end
  
  # 删除收藏微博
  #
  # == 参数：
  #  id/tweet_id: 微博 id
  #
  # 返回被收藏到微博到详细信息
  def destroy
    @tweet = Tweet.find(params[:id] || params[:tweet_id])
    current_user.unfavorite!(@tweet)
    render :json => true
  end
end
