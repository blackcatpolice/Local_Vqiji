# encoding: utf-8

# 微博
class TweetsController < WeiboController
  
  # 获取一条微博的详细信息
  #
  # == 参数：
  #  id: 微博 id
  #
  # 返回微博的详细信息
  def show
    @tweet = Tweet.find(params[:id])
    
    respond_to do |format|
      format.json { render :json => @tweet.as_json }
      format.html {
        # 显示转发
        @reposts = @tweet.reposts
         .includes(:sender)
         .paginate(:page => params[:page], :per_page => 10)

        render 'tweet/reposts/index'
      }
    end
  end

  # 创建（发布） 一条微博（不带附件）
  #
  # == 参数：
  #  text: 微博 text
  #
  # 返回创建的微博
  def create
    @tweet = current_user.tweet(params)
    
    respond_to do |format|
      format.json { render :json => @tweet.as_json }
      format.html {
        render :partial => "/tweets/tweet", :object => @tweet
      }
    end
  end
  
  # 删除微博
  #
  # == 参数：
  #  id: 微博 id
  #
  # 返回 删除成功提示
  def destroy
    @tweet = Tweet.find(params[:id])
    
    current_user.delete_tweet!(@tweet)
    respond_to do |format|
      format.json { render :json => @tweet.as_json }
    end
  end
end
