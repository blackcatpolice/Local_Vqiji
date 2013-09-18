# encoding: utf-8

# 当前用户收藏的微博
class My::FavoritesController < WeiboController
  # 查看收藏
  def index
    @favorites = current_user.favorites
      .includes(:tweet)
      .paginate(:page => params[:page], :per_page => 20)
    @tweets = @favorites.collect &:tweet
  end
  
  def index_untagged
    @favorites = current_user.favorites.untagged
      .includes(:tweet)
      .paginate(:page => params[:page], :per_page => 20)
    @tweets = @favorites.collect &:tweet
  end
  
  def index_tagged
    @tag = params[:tag]
    (redirect_to(:action => :index) and return) if @tag.blank?
    
    @favorites = current_user.favorites.tagged_with(@tag)
      .includes(:tweet)
      .paginate(:page => params[:page], :per_page => 20)
    @tweets = @favorites.collect &:tweet
  end

  # 收藏微博
  def create
    tweet = Tweet.find(params[:tweet_id])
    @favorite = current_user.favorite(tweet, params[:tags])
    render '_favorite'
  end
  
  # 设置收藏的 tag
  def set_tags
    tweet = Tweet.find(params[:tweet_id])
    @favorite = current_user.favorite(tweet)
    current_user.favorite_service.set_tags!(@favorite, params[:tags])
    render '_favorite'
  end
  
  # 删除收藏
  def destroy
    tweet = Tweet.find_by_id(params[:tweet_id])
    current_user.unfavorite!(tweet) if tweet
    render :json => true
  end

  def set_tags_tip
    @tweet = Tweet.find(params[:tweet_id])
    @tags = current_user.favorite_service.tags
    render :layout => false
  end
end
