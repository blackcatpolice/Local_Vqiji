# encoding: utf-8

# 话题控制器
class TopicsController < WeiboController

  # 获取话题列表
  def index
    @topics = Topic.all
      .paginate(:page => params[:page])
  end
  
  # 显示话题
  def show
    @topic = Topic.find_or_create_by(:title => params[:id])
    
    respond_to do |format|
      format.html {
        @tweets = @topic.hall_tweets
          .paginate(:page => params[:page], :per_page => 10)
      }
    end
  end
end
