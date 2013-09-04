# encoding: utf-8

# 微博评论
class Tweet::CommentsController < WeiboController

  # 获取评论列表
  # 
  # == 参数：
  #  tweet_id
  #  [分页]
  #
  def index
    @tweet = Tweet.find(params[:tweet_id])
    @comments = @tweet.comments.includes(:sender)
     .paginate(:page => params[:page], :per_page => 10)
    
    respond_to do |format|
      format.html
    end
  end

  def list
    @tweet = Tweet.find(params[:tweet_id])
    @comments = @tweet.comments.includes(:sender)
      .paginate(:page => params[:page], :per_page => 10)
    render :layout => nil
  end
  
  # 获取评论详细
  def show
    @comment = Comment.find(params[:id])
    
    respond_to do |format|
      format.json { render :json => @comment.as_json }
    end
  end
  
  # 创建评论
  # 
  # == 参数：
  #  tweet_id
  #  text
  #
  # 返回被创建的评论
  def create
    @comment = current_user.send_comment params

    respond_to do |format|
      format.json
    end
  end

  # 新建评论
  def new
    @tweet = Tweet.find(params[:tweet_id])
    @comment = Comment.find(params[:comment_id])
    respond_to do |format|
      format.json {
        render :json => {
          preset: @preset,
          tweet: @tweet.as_json
        }
      }
      #
      format.html{
        render :layout => nil
      }
    end
  end
  
  # 删除评论
  # 
  # == 参数：
  #  * id 评论 id, 你懂的～！
  #
  # 返回被删除的评论
  def destroy
    @comment = Comment.find(params[:id])
    current_user.delete_comment!(@comment)
    
    respond_to do |format|
      format.json { render :json => @comment.as_json }
    end
  end
end
