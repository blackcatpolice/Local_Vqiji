# encoding: utf-8

# 微博转发
class Tweet::RepostsController < WeiboController

  # 获取微博的转发微博
  #
  # == 参数：
  #  [分页]
  #
  # 返回创建的微博
  def index
    @tweet = Tweet.repostable.find(params[:tweet_id])
    @reposts = @tweet.reposts.includes(:sender)
     .paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.json { render :json => @tweets.as_json }
      format.html
    end
  end
  
  # 新建转发
  def new
    @tweet = Tweet.find_by_id(params[:tweet_id])
    raise WeiboError, '微博不存在' unless @tweet
    raise WeiboError, '该微博不能转发' unless @tweet.repostable? 

    render :layout => false
  end
  
  # 转发（发布） 一条微博
  #
  # == 参数：
  #  text: 微博 text
  #  tweet_id
  #
  # 返回创建的微博
  def create
    @tweet = Tweet.find(params[:tweet_id])
    @repost_tweet = current_user.repost(@tweet, params[:text])
    
    respond_to do |format|
      format.json { render :json => @repost_tweet.as_json }
      format.html {
        render :partial => (params[:_tmpl] || 'tweets/tweet'), :object => @repost_tweet
      }
    end
  end

end
